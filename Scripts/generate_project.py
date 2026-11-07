#!/usr/bin/env python3
"""Generate the dependency-free Xcode project with a local CurioCore package."""
import hashlib
import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[1]
objects = {}


def uid(key):
    return hashlib.sha1(key.encode()).hexdigest()[:24].upper()


def add(key, isa, **values):
    objects[uid(key)] = dict(isa=isa, **values)
    return uid(key)


def configs(key, settings):
    configurations = []
    for name in ["Debug", "Release"]:
        build = dict(settings)
        build.update(SWIFT_OPTIMIZATION_LEVEL="-Onone" if name == "Debug" else "-O",
                     DEBUG_INFORMATION_FORMAT="dwarf" if name == "Debug" else "dwarf-with-dsym")
        if name == "Debug":
            build.update(ENABLE_TESTABILITY="YES", ONLY_ACTIVE_ARCH="YES",
                         SWIFT_ACTIVE_COMPILATION_CONDITIONS="DEBUG $(inherited)")
        configurations.append(add(key + name, "XCBuildConfiguration", name=name, buildSettings=build))
    return add(key + "List", "XCConfigurationList", buildConfigurations=configurations,
               defaultConfigurationIsVisible=0, defaultConfigurationName="Release")


common = dict(CLANG_ENABLE_MODULES="YES", CLANG_ENABLE_OBJC_ARC="YES", SDKROOT="appletvos",
              TVOS_DEPLOYMENT_TARGET="26.0", SWIFT_VERSION="6.0", SWIFT_STRICT_CONCURRENCY="complete")
app_settings = dict(CODE_SIGN_STYLE="Automatic", CURRENT_PROJECT_VERSION="4", MARKETING_VERSION="0.4.0",
                    ASSETCATALOG_COMPILER_APPICON_NAME="App Icon & Top Shelf Image",
                    GENERATE_INFOPLIST_FILE="YES", INFOPLIST_KEY_CFBundleDisplayName="CurioTV",
                    INFOPLIST_KEY_LSApplicationCategoryType="public.app-category.entertainment",
                    INFOPLIST_KEY_UIApplicationSceneManifest_Generation="YES",
                    INFOPLIST_KEY_UILaunchScreen_Generation="YES", PRODUCT_BUNDLE_IDENTIFIER="com.example.CurioTV",
                    PRODUCT_NAME="$(TARGET_NAME)", SUPPORTED_PLATFORMS="appletvos appletvsimulator",
                    TARGETED_DEVICE_FAMILY="3", SWIFT_EMIT_LOC_STRINGS="YES", ENABLE_USER_SCRIPT_SANDBOXING="YES")
test_settings = dict(CODE_SIGN_STYLE="Automatic", GENERATE_INFOPLIST_FILE="YES",
                     PRODUCT_BUNDLE_IDENTIFIER="com.example.CurioTV.uitests", PRODUCT_NAME="$(TARGET_NAME)",
                     SUPPORTED_PLATFORMS="appletvos appletvsimulator", TARGETED_DEVICE_FAMILY="3",
                     TEST_TARGET_NAME="CurioTV")
app_group = add("AppGroup", "PBXFileSystemSynchronizedRootGroup", path="CurioTV", sourceTree="<group>")
test_group = add("TestGroup", "PBXFileSystemSynchronizedRootGroup", path="CurioTVUITests", sourceTree="<group>")
app_product = add("AppProduct", "PBXFileReference", explicitFileType="wrapper.application", includeInIndex=0,
                  path="CurioTV.app", sourceTree="BUILT_PRODUCTS_DIR")
test_product = add("TestProduct", "PBXFileReference", explicitFileType="wrapper.cfbundle", includeInIndex=0,
                   path="CurioTVUITests.xctest", sourceTree="BUILT_PRODUCTS_DIR")
products = add("Products", "PBXGroup", children=[app_product, test_product], name="Products", sourceTree="<group>")
main = add("Main", "PBXGroup", children=[app_group, test_group, products], sourceTree="<group>")
package = add("Package", "XCLocalSwiftPackageReference", relativePath=".")
core = add("Core", "XCSwiftPackageProductDependency", package=package, productName="CurioCore")
core_build = add("CoreBuild", "PBXBuildFile", productRef=core)
proxy = add("Proxy", "PBXContainerItemProxy", containerPortal=uid("Project"), proxyType=1,
            remoteGlobalIDString=uid("App"), remoteInfo="CurioTV")
dependency = add("Dependency", "PBXTargetDependency", target=uid("App"), targetProxy=proxy)
for key, name, group, product, product_type, settings in [
    ("App", "CurioTV", app_group, app_product, "application", app_settings),
    ("Tests", "CurioTVUITests", test_group, test_product, "bundle.ui-testing", test_settings),
]:
    phases = [add(key + phase, "PBX" + phase + "BuildPhase", buildActionMask=2147483647,
                  files=[core_build] if key == "App" and phase == "Frameworks" else [], runOnlyForDeploymentPostprocessing=0)
              for phase in ["Sources", "Frameworks", "Resources"]]
    add(key, "PBXNativeTarget", buildConfigurationList=configs(key, dict(common, **settings)), buildPhases=phases,
        buildRules=[], dependencies=[dependency] if key == "Tests" else [], fileSystemSynchronizedGroups=[group],
        name=name, productName=name, productReference=product, productType="com.apple.product-type." + product_type,
        packageProductDependencies=[core] if key == "App" else [])
add("Project", "PBXProject", attributes=dict(BuildIndependentTargetsInParallel="YES", LastUpgradeCheck="2700",
    TargetAttributes={uid("App"): {"CreatedOnToolsVersion": "27.0"},
                      uid("Tests"): {"CreatedOnToolsVersion": "27.0", "TestTargetID": uid("App")}}),
    buildConfigurationList=configs("Project", common), compatibilityVersion="Xcode 16.0", developmentRegion="en",
    hasScannedForEncodings=0, knownRegions=["en", "Base"], mainGroup=main, productRefGroup=products,
    minimizedProjectReferenceProxies=1, preferredProjectObjectVersion=77, projectDirPath="", projectRoot="",
    packageReferences=[package], targets=[uid("App"), uid("Tests")])


def serialize(value):
    if isinstance(value, dict):
        return "{ " + " ".join(f"{json.dumps(k)} = {serialize(v)};" for k, v in value.items()) + " }"
    if isinstance(value, list):
        return "( " + ", ".join(serialize(v) for v in value) + " )"
    return str(value) if isinstance(value, int) else json.dumps(value)


project = ROOT / "CurioTV.xcodeproj"
project.mkdir(exist_ok=True)
(project / "project.pbxproj").write_text("// !$*UTF8*$!\n" + serialize(dict(
    archiveVersion=1, classes={}, objectVersion=77, objects=objects, rootObject=uid("Project"))) + "\n")
schemes = project / "xcshareddata/xcschemes"
schemes.mkdir(parents=True, exist_ok=True)
reference = f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{uid("App")}" BuildableName="CurioTV.app" BlueprintName="CurioTV" ReferencedContainer="container:CurioTV.xcodeproj"/>'
test_reference = f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{uid("Tests")}" BuildableName="CurioTVUITests.xctest" BlueprintName="CurioTVUITests" ReferencedContainer="container:CurioTV.xcodeproj"/>'
(schemes / "CurioTV.xcscheme").write_text(f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="2700" version="1.7">
  <BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries>
    <BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">{reference}</BuildActionEntry>
  </BuildActionEntries></BuildAction>
  <TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES">
    <Testables><TestableReference skipped="NO" parallelizable="NO">{test_reference}</TestableReference></Testables>
  </TestAction>
  <LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES"><BuildableProductRunnable runnableDebuggingMode="0">{reference}</BuildableProductRunnable></LaunchAction>
  <ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES"><BuildableProductRunnable runnableDebuggingMode="0">{reference}</BuildableProductRunnable></ProfileAction>
  <AnalyzeAction buildConfiguration="Debug"/>
  <ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/>
</Scheme>
''')
print(project)
