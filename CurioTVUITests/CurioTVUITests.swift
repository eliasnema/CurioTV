import XCTest

@MainActor
final class CurioTVUITests: XCTestCase {
    private let remote = XCUIRemote.shared

    override func setUpWithError() throws { continueAfterFailure = false }

    func testSavePersistsAndUnavailableYouTubeHasAnHonestFallback() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Stay curious."].waitForExistence(timeout: 15))
        capture(app, "01-discover")
        remote.press(.down)
        focus(app.buttons["hero.pick"], direction: .left)
        remote.press(.select)
        XCTAssertTrue(app.buttons["video.watch"].waitForExistence(timeout: 10))
        let save = app.buttons["video.save"]
        focus(save, direction: .down)
        if save.label != "Saved to My Library" { remote.press(.select) }
        XCTAssertEqual(save.label, "Saved to My Library")
        capture(app, "02-video-saved")
        focus(app.buttons["video.watch"], direction: .up)
        remote.press(.select)
        XCTAssertTrue(app.staticTexts["YouTube couldn't be opened"].waitForExistence(timeout: 10))
        capture(app, "03-youtube-fallback")
        app.terminate()
        app.launch()
        XCTAssertTrue(app.staticTexts["Stay curious."].waitForExistence(timeout: 10))
        focus(app.buttons["My Library"], direction: .right)
        remote.press(.select)
        XCTAssertTrue(app.staticTexts["Saved for later"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["video.RpslsMqPFWA"].exists)
        XCTAssertFalse(app.staticTexts["Opened in YouTube"].exists, "Failed link openings must not be recorded as watched or opened")
        capture(app, "04-library-after-relaunch")
    }

    func testRemoteTierFilterAndChannelUploads() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Stay curious."].waitForExistence(timeout: 10))
        focus(app.buttons["Channels"], direction: .right)
        remote.press(.select)
        XCTAssertTrue(app.textFields.firstMatch.waitForExistence(timeout: 10))
        focus(app.buttons["All tiers"], direction: .down)
        focus(app.buttons["Tier S"], direction: .right)
        remote.press(.select)
        XCTAssertTrue(app.staticTexts["5 of 156 channels · Selection by Tristan Hume"].waitForExistence(timeout: 5))
        capture(app, "05-channels-s-tier")
        focus(app.buttons["channel.UCivA7_KLKWo43tFcCkFvydw"], direction: .down)
        remote.press(.select)
        XCTAssertTrue(app.staticTexts["Recent uploads"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["Open channel in YouTube"].exists)
        capture(app, "06-channel-detail")
        let upload = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'upload.'")).firstMatch
        for _ in 0..<4 {
            if upload.exists { break }
            remote.press(.down)
        }
        if app.staticTexts["YouTube's recent uploads are unavailable. Try again in a moment."].exists {
            capture(app, "public-feed-unavailable")
            throw XCTSkip("Public YouTube RSS is unavailable. Channel navigation and the official-app fallback were verified; live upload selection cannot be tested.")
        }
        XCTAssertTrue(upload.waitForExistence(timeout: 25), "A live public feed should produce recent-upload cards. \(app.debugDescription)")
        focus(upload, direction: .down)
        remote.press(.select)
        XCTAssertTrue(app.buttons["video.watch"].waitForExistence(timeout: 10))
        capture(app, "07-recent-upload-detail")
    }

    func testSettingsExplainTheYouTubeAccountHandoff() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Stay curious."].waitForExistence(timeout: 10))
        focus(app.buttons["Settings"], direction: .right)
        remote.press(.select)
        XCTAssertTrue(app.staticTexts["Sign in once, in YouTube."].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["settings.openYouTube"].exists)
        capture(app, "08-account-settings")
    }

    private func focus(_ element: XCUIElement, direction: XCUIRemote.Button, file: StaticString = #filePath, line: UInt = #line) {
        RemoteFocus.move(to: element, preferred: direction, file: file, line: line)
    }

    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
