import XCTest

final class MobileFlowTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor func testTwoScreenNavigationAndSampleNote() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Leads & Activity"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["demo-banner"].exists)
        XCTAssertEqual(app.tabBars.count, 0)
        capture("Leads and Activity")
        app.buttons["filter-hot"].tap()
        let lead = app.buttons["open-lead-00000000-0000-4000-8000-000000000001"]
        XCTAssertTrue(lead.waitForExistence(timeout: 10))
        lead.tap()
        XCTAssertTrue(app.buttons["back-to-dashboard"].waitForExistence(timeout: 10))
        capture("Lead Details")
        swipeTo(app.buttons["add-note"], in: app)
        app.buttons["add-note"].tap()
        let input = app.textViews["note-input"]
        XCTAssertTrue(input.waitForExistence(timeout: 3))
        input.tap()
        input.typeText("UI test sample note")
        app.buttons["save-note"].tap()
        XCTAssertTrue(app.staticTexts["UI test sample note"].waitForExistence(timeout: 3))
        if app.buttons["Dismiss confirmation"].exists { app.buttons["Dismiss confirmation"].tap() }
        for _ in 0..<5 where !app.buttons["back-to-dashboard"].isHittable { app.swipeDown() }
        app.buttons["back-to-dashboard"].tap()
        XCTAssertTrue(app.buttons["filter-hot"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.tabBars.count, 0)
    }

    @MainActor func testNotificationAndAccountAreSheets() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["demo-banner"].waitForExistence(timeout: 10))
        app.buttons["account"].tap()
        XCTAssertTrue(app.navigationBars["Account"].waitForExistence(timeout: 10))
        app.buttons["Close"].tap()
        XCTAssertTrue(app.navigationBars["Account"].waitForNonExistence(timeout: 10))
        app.buttons["notifications"].tap()
        XCTAssertTrue(app.navigationBars["Notifications"].waitForExistence(timeout: 3))
        XCTAssertGreaterThan(app.switches.count, 0)
        app.buttons["Close"].tap()
        XCTAssertTrue(app.buttons["filter-mine"].exists)
        XCTAssertEqual(app.tabBars.count, 0)
    }

    @MainActor private func swipeTo(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<8 {
            if element.isHittable { return }
            app.swipeUp()
        }
        XCTAssertTrue(element.isHittable)
    }

    @MainActor private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
