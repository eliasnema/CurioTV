import XCTest

@MainActor
final class CurationUITests: XCTestCase {
    private let remote = XCUIRemote.shared

    override func setUpWithError() throws { continueAfterFailure = false }

    func testCustomChannelKeyboardEntryAndSingleTierMove() {
        let app = XCUIApplication()
        app.launch()
        focus(app.buttons["Collections"], .right)
        remote.press(.select)
        focus(app.buttons["collections.create"], .down)
        remote.press(.select)
        let field = app.textFields["collection.name"]
        XCTAssertTrue(field.waitForExistence(timeout: 10))
        let name = field.value as? String ?? "My picks"
        focus(app.buttons["collection.save"], .down)
        remote.press(.select)
        let row = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'collection.' AND label CONTAINS %@", name)).firstMatch
        focus(row, .down)
        remote.press(.select)
        focus(app.buttons["collection.addLink"], .right)
        remote.press(.select)
        enter("Example test channel", into: app.textFields["curation.channelName"], app: app)
        let id = "UC0000000000000000000000"
        enter("https://www.youtube.com/channel/\(id)", into: app.textFields["curation.channelLink"], app: app)
        focus(app.buttons["curation.addCustom"], .down)
        remote.press(.select)
        let move = app.buttons["curation.move.\(id)"]
        XCTAssertTrue(move.waitForExistence(timeout: 10))
        focus(move, .down)
        remote.press(.select)
        focus(app.buttons["A tier"].firstMatch, .down)
        remote.press(.select)
        let changed = XCTNSPredicateExpectation(predicate: NSPredicate(format: "label CONTAINS '1'"), object: app.staticTexts["collection.tier.A"])
        XCTAssertEqual(XCTWaiter.wait(for: [changed], timeout: 5), .completed)
        capture(app, "12-custom-channel-moved")
        remote.press(.menu)
        focus(app.buttons["Use Tristan's collection"], .up)
        remote.press(.select)
    }

    private func enter(_ text: String, into field: XCUIElement, app: XCUIApplication) {
        focus(field, .down)
        remote.press(.select)
        app.typeText(text)
        remote.press(.menu)
        XCTAssertEqual(field.value as? String, text)
    }

    func testCreateBulkCopySetLimitsAndPersistPersonalCollection() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["Collections"].waitForExistence(timeout: 15))
        focus(app.buttons["Collections"], .right)
        remote.press(.select)
        focus(app.buttons["collections.create"], .down)
        remote.press(.select)
        let nameField = app.textFields["collection.name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 10))
        let name = nameField.value as? String ?? "My picks"
        remote.press(.down)
        remote.press(.down)
        focus(app.buttons["collection.save"], .left)
        remote.press(.select)
        let row = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'collection.' AND label CONTAINS %@", name)).firstMatch
        focus(row, .down)
        remote.press(.select)
        focus(app.buttons["collection.addChannels"], .right)
        remote.press(.select)
        focus(app.buttons["curation.selectAll"], .down)
        remote.press(.select)
        focus(app.buttons["curation.addSelected"], .left)
        remote.press(.select)
        XCTAssertTrue(app.staticTexts["156 channels · Your own tiers"].waitForExistence(timeout: 10))
        capture(app, "09-personal-collection")

        focus(app.buttons["collection.limits"], .down)
        remote.press(.select)
        focus(app.buttons["curation.limit.S"], .down)
        remote.press(.select)
        focus(app.buttons["5 channels"].firstMatch, .down)
        remote.press(.select)
        let limitUpdated = XCTNSPredicateExpectation(predicate: NSPredicate(format: "label CONTAINS 'Maximum 5'"), object: app.buttons["curation.limit.S"])
        XCTAssertEqual(XCTWaiter.wait(for: [limitUpdated], timeout: 5), .completed, app.debugDescription)
        capture(app, "10-tier-limits")
        remote.press(.menu)

        focus(app.buttons["collection.addChannels"], .up)
        remote.press(.select)
        focus(app.buttons["curation.tier.S"], .down)
        remote.press(.select)
        focus(app.buttons["curation.selectAll"], .down)
        remote.press(.select)
        focus(app.buttons["curation.addSelected"], .left)
        remote.press(.select)
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'this change would contain 156'")).firstMatch.waitForExistence(timeout: 10))
        capture(app, "11-full-tier-rejected")
        remote.press(.menu)
        XCTAssertTrue(app.staticTexts["156 channels · Your own tiers"].waitForExistence(timeout: 10))

        app.terminate()
        app.launch()
        focus(app.buttons["Collections"], .right)
        remote.press(.select)
        let persisted = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'collection.' AND label CONTAINS %@", name)).firstMatch
        focus(persisted, .down)
        remote.press(.select)
        XCTAssertTrue(app.staticTexts["collection.tier.S"].label.contains("5 / 5 maximum"))
        XCTAssertTrue(app.staticTexts["156 channels · Your own tiers"].exists)
        remote.press(.menu)
        focus(app.buttons["Use Tristan's collection"], .up)
        remote.press(.select)
        XCTAssertTrue(app.staticTexts["Browsing: Tristan's collection"].waitForExistence(timeout: 5))
    }

    private func focus(_ element: XCUIElement, _ direction: XCUIRemote.Button, file: StaticString = #filePath, line: UInt = #line) {
        RemoteFocus.move(to: element, preferred: direction, file: file, line: line)
    }

    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
