import XCTest
import UIKit
@testable import MazarineOPSMobile

final class DemoStoreTests: XCTestCase {
    @MainActor func testOriginalBrandResourcesAreAvailable() {
        XCTAssertNotNil(UIImage(named: "MZLogo"))
        XCTAssertNotNil(UIFont(name: "Manrope-Bold", size: 24))
        XCTAssertNotNil(UIFont(name: "AvenirNext-Regular", size: 15))
    }

    @MainActor func testCountsComeFromSampleRecords() {
        let store = DemoStore()
        XCTAssertEqual(store.count(.activity), 5)
        XCTAssertEqual(store.count(.hot), 1)
        XCTAssertEqual(store.count(.mine), 3)
        XCTAssertEqual(store.count(.followUps), 2)
    }

    @MainActor func testFiltersAndSearchCompose() {
        let store = DemoStore()
        store.filter = .hot
        XCTAssertEqual(store.filteredLeads.map(\.id), [DemoData.jamesID])
        store.search = "robert"
        XCTAssertTrue(store.filteredLeads.isEmpty)
        store.filter = .mine
        XCTAssertEqual(store.filteredLeads.map(\.id), [DemoData.robertID])
        XCTAssertEqual(store.filteredActivities.count, 2)
        store.filter = .followUps
        XCTAssertEqual(store.filteredLeads.count, 1)
    }

    @MainActor func testReadingLeadOnlyClearsItsActivity() {
        let store = DemoStore()
        store.markRead(DemoData.jamesID)
        XCTAssertEqual(store.unreadCount, 3)
        XCTAssertTrue(store.history(DemoData.jamesID).allSatisfy { !$0.unread })
    }

    @MainActor func testNoteUpdatesDetailsAndHistory() {
        let store = DemoStore()
        store.addNote("  Sample note  ", to: DemoData.jamesID)
        XCTAssertEqual(store.lead(DemoData.jamesID)?.notes.first?.body, "Sample note")
        XCTAssertEqual(store.history(DemoData.jamesID).first?.kind, .noteAdded)
        XCTAssertTrue(store.notice?.contains("only") == true)
        store.addNote("  ", to: DemoData.jamesID)
        XCTAssertEqual(store.lead(DemoData.jamesID)?.notes.count, 3)
    }

    @MainActor func testStatusChangeAndLostValidation() {
        let store = DemoStore()
        store.updateStatus(.lost, reason: "", leadID: DemoData.jamesID)
        XCTAssertEqual(store.lead(DemoData.jamesID)?.status, .inProgress)
        store.updateStatus(.lost, reason: "Timing", leadID: DemoData.jamesID)
        XCTAssertEqual(store.lead(DemoData.jamesID)?.status, .lost)
        XCTAssertEqual(store.history(DemoData.jamesID).first?.kind, .statusChanged)
        let count = store.activities.count
        store.updateStatus(.lost, reason: "Timing", leadID: DemoData.jamesID)
        XCTAssertEqual(store.activities.count, count)
    }

    @MainActor func testFollowUpSchedulingAndCompletion() {
        let store = DemoStore()
        store.scheduleFollowUp(leadID: DemoData.davidID, date: .now.addingTimeInterval(3600), note: "Call", reminder: true)
        XCTAssertEqual(store.pendingFollowUps, 3)
        guard let followUp = store.lead(DemoData.davidID)?.followUps.first else { return XCTFail("Missing follow-up") }
        store.completeFollowUp(leadID: DemoData.davidID, followUpID: followUp.id)
        XCTAssertEqual(store.pendingFollowUps, 2)
        store.scheduleFollowUp(leadID: DemoData.davidID, date: .distantPast, note: "", reminder: false)
        XCTAssertEqual(store.pendingFollowUps, 2)
    }

    @MainActor func testRefreshPreservesSampleEdits() async {
        let store = DemoStore()
        store.addNote("Keep this draft", to: DemoData.jamesID)
        await store.refresh()
        XCTAssertEqual(store.lead(DemoData.jamesID)?.notes.first?.body, "Keep this draft")
    }

    @MainActor func testOpenedOnlyDoesNotFabricateModelOrPrice() {
        let store = DemoStore()
        let configuration = store.lead(DemoData.davidID)?.configurations.first
        XCTAssertNil(configuration?.model)
        XCTAssertNil(configuration?.total)
        XCTAssertEqual(configuration?.summary, "Opened - no saved selections")
        XCTAssertTrue(store.leads.allSatisfy { $0.phone == nil })
        XCTAssertTrue(store.leads.allSatisfy { $0.email?.hasSuffix("@example.com") == true })
    }
}
