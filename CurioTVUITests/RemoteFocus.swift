import XCTest

@MainActor
enum RemoteFocus {
    /// Uses accessibility frames to choose remote directions; every interaction still goes through XCUIRemote.
    static func move(to element: XCUIElement, preferred: XCUIRemote.Button,
                     file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(element.waitForExistence(timeout: 10), file: file, line: line)
        var previousFrame: CGRect?
        for _ in 0..<24 {
            if element.hasFocus || element.descendants(matching: .button).allElementsBoundByIndex.contains(where: \.hasFocus) { return }
            var direction = preferred
            let focused = XCUIApplication().descendants(matching: .any).matching(NSPredicate(format: "hasFocus == true")).firstMatch
            if focused.exists {
                let current = focused.frame
                let target = element.frame
                if target.maxY < current.minY { direction = .up }
                else if target.minY > current.maxY { direction = .down }
                else if target.midX < current.midX { direction = .left }
                else { direction = .right }
                if let previousFrame, abs(previousFrame.midX - current.midX) < 2,
                   abs(previousFrame.midY - current.midY) < 2,
                   target.maxY < current.minY || target.minY > current.maxY {
                    direction = target.midX < current.midX ? .left : .right
                }
                previousFrame = current
            }
            XCUIRemote.shared.press(direction)
        }
        XCTFail("Could not focus \(element.identifier): \(element.label). \(XCUIApplication().debugDescription)", file: file, line: line)
    }
}
