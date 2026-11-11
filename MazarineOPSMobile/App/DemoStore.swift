import Foundation
import Observation

@MainActor @Observable
final class DemoStore {
    private(set) var leads: [Lead]
    private(set) var activities: [LeadActivity]
    var filter = DashboardFilter.activity
    var search = ""
    var selectedLeadID: UUID? = DemoData.jamesID
    var sheet: SalesSheet?
    var notice: String?
    var notificationCategories = Set(ActivityKind.allCases)
    private(set) var lastRefreshedAt: Date

    init(now: Date = .now) {
        leads = DemoData.leads(now: now)
        activities = DemoData.activities(now: now)
        lastRefreshedAt = now
    }

    func lead(_ id: UUID) -> Lead? { leads.first { $0.id == id } }
    var unreadCount: Int { activities.filter(\.unread).count }
    var pendingFollowUps: Int { leads.flatMap(\.followUps).filter { !$0.completed }.count }

    func count(_ filter: DashboardFilter) -> Int {
        switch filter {
        case .activity: unreadCount
        case .hot: leads.filter { $0.temperature == .hot }.count
        case .mine: leads.filter(\.assignedToMe).count
        case .followUps: pendingFollowUps
        }
    }

    var filteredLeads: [Lead] {
        leads.filter { lead in
            let matchesFilter: Bool
            switch filter {
            case .activity: matchesFilter = activities.contains { $0.leadID == lead.id }
            case .hot: matchesFilter = lead.temperature == .hot
            case .mine: matchesFilter = lead.assignedToMe
            case .followUps: matchesFilter = lead.followUps.contains { !$0.completed }
            }
            return matchesFilter && matchesSearch(lead)
        }
    }

    var filteredActivities: [LeadActivity] {
        activities.filter { activity in
            guard let lead = lead(activity.leadID) else { return false }
            return matchesSearch(lead)
        }
    }

    func history(_ leadID: UUID) -> [LeadActivity] {
        activities.filter { $0.leadID == leadID }.sorted { $0.occurredAt > $1.occurredAt }
    }

    func markRead(_ leadID: UUID) {
        for index in activities.indices where activities[index].leadID == leadID {
            activities[index].unread = false
        }
    }

    func addNote(_ body: String, to id: UUID) {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let index = leads.firstIndex(where: { $0.id == id }) else { return }
        leads[index].notes.insert(LeadNote(id: UUID(), body: trimmed, author: "Demo Salesperson", createdAt: .now), at: 0)
        appendActivity(id, .noteAdded, trimmed)
        notice = "Sample note saved on this device only."
    }

    func updateStatus(_ status: LeadStatus, reason: String, leadID: UUID) {
        guard let index = leads.firstIndex(where: { $0.id == leadID }) else { return }
        guard status != .lost || !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            notice = "Choose a reason for marking this sample Lead Lost."
            return
        }
        let previous = leads[index].status
        guard previous != status else { return }
        leads[index].status = status
        appendActivity(leadID, .statusChanged, "\(previous.title) → \(status.title)\(reason.isEmpty ? "" : ": \(reason)")")
        notice = "Sample status updated. OPS was not changed."
    }

    func scheduleFollowUp(leadID: UUID, date: Date, note: String, reminder: Bool) {
        guard let index = leads.firstIndex(where: { $0.id == leadID }) else { return }
        guard date > .now else {
            notice = "Choose a future follow-up date."
            return
        }
        leads[index].followUps.append(FollowUp(id: UUID(), dueAt: date, note: note, reminder: reminder))
        appendActivity(leadID, .followUpScheduled, date.formatted(date: .abbreviated, time: .shortened))
        notice = "Sample follow-up saved. No reminder will be delivered."
    }

    func completeFollowUp(leadID: UUID, followUpID: UUID) {
        guard let leadIndex = leads.firstIndex(where: { $0.id == leadID }),
              let index = leads[leadIndex].followUps.firstIndex(where: { $0.id == followUpID }) else { return }
        leads[leadIndex].followUps[index].completed = true
        notice = "Sample follow-up completed."
    }

    func logCall(leadID: UUID, outcome: String) {
        appendActivity(leadID, .callLogged, outcome)
        notice = "Sample call outcome saved. No call was placed."
    }

    func refresh() async {
        // Demo refresh never replaces unsent sample edits or contacts production.
        lastRefreshedAt = .now
    }

    private func appendActivity(_ leadID: UUID, _ kind: ActivityKind, _ detail: String) {
        activities.insert(LeadActivity(id: UUID(), leadID: leadID, kind: kind, detail: detail, occurredAt: .now, unread: false), at: 0)
    }

    private func matchesSearch(_ lead: Lead) -> Bool {
        let query = search.trimmingCharacters(in: .whitespacesAndNewlines)
        return query.isEmpty || [lead.name, lead.email ?? "", lead.model, lead.boat?.name ?? ""]
            .contains { $0.localizedCaseInsensitiveContains(query) }
    }
}
