import Foundation

enum LeadTemperature: String, CaseIterable, Sendable {
    case hot, warm, cold

    var title: String { "\(rawValue.capitalized) Lead" }
}

enum LeadStatus: String, CaseIterable, Identifiable, Sendable {
    case imported, new, firstTouchComplete, responded, inProgress, lost, archived

    var id: String { rawValue }
    var title: String {
        switch self {
        case .firstTouchComplete: "First Touch Complete"
        case .inProgress: "In Progress"
        default: rawValue.capitalized
        }
    }
}

struct LeadNote: Identifiable, Equatable, Sendable {
    let id: UUID
    let body: String
    let author: String
    let createdAt: Date
}

struct Boat: Equatable, Sendable {
    let name: String
    let make: String
    let model: String
    let year: String
}

struct Configuration: Identifiable, Equatable, Sendable {
    let id: UUID
    let model: String?
    let options: [String]
    let total: Decimal?
    let coupon: String?
    let status: String
    let openedAt: Date?
    let submittedAt: Date?

    var summary: String { model ?? "Opened - no saved selections" }
}

struct FollowUp: Identifiable, Equatable, Sendable {
    let id: UUID
    var dueAt: Date
    var note: String
    var reminder: Bool
    var completed = false
}

struct Lead: Identifiable, Equatable, Sendable {
    let id: UUID
    let name: String
    let email: String?
    let phone: String?
    let location: String?
    let source: String
    let createdAt: Date
    let salesperson: String
    let assignedToMe: Bool
    let timeframe: String?
    let temperature: LeadTemperature
    var status: LeadStatus
    let boat: Boat?
    let configurations: [Configuration]
    var notes: [LeadNote]
    var followUps: [FollowUp]

    var model: String { configurations.first?.model ?? "No model selected" }
}

enum ActivityKind: String, CaseIterable, Identifiable, Sendable {
    case newLead, assigned, reassigned, configuratorOpened, configuratorReopened
    case submitted, quoteRequested, campaignClicked, waitlist, becameHot
    case customerResponded, followUpDue, followUpScheduled, statusChanged, noteAdded, callLogged

    var id: String { rawValue }
    var title: String {
        switch self {
        case .newLead: "New Lead Created"
        case .assigned: "New Lead Assigned"
        case .reassigned: "Lead Reassigned"
        case .configuratorOpened: "Configurator Opened"
        case .configuratorReopened: "Configurator Reopened"
        case .submitted: "Configuration Submitted"
        case .quoteRequested: "Quote Requested"
        case .campaignClicked: "Campaign Link Clicked"
        case .waitlist: "Joined Model Waitlist"
        case .becameHot: "Lead Became Hot"
        case .customerResponded: "Customer Responded"
        case .followUpDue: "Follow-up Due"
        case .followUpScheduled: "Follow-up Scheduled"
        case .statusChanged: "Lead Status Changed"
        case .noteAdded: "Internal Note Added"
        case .callLogged: "Call Outcome Logged"
        }
    }

    var symbol: String {
        switch self {
        case .becameHot: "flame"
        case .configuratorOpened, .configuratorReopened: "eye"
        case .submitted, .quoteRequested: "doc.text"
        case .newLead, .assigned, .reassigned: "person.badge.plus"
        case .campaignClicked: "link"
        case .waitlist: "clock"
        case .customerResponded: "bubble.left"
        case .followUpDue, .followUpScheduled: "calendar"
        case .statusChanged: "checkmark.circle"
        case .noteAdded: "note.text"
        case .callLogged: "phone"
        }
    }
}

struct LeadActivity: Identifiable, Equatable, Sendable {
    let id: UUID
    let leadID: UUID
    let kind: ActivityKind
    let detail: String
    let occurredAt: Date
    var unread: Bool
}

enum DashboardFilter: String, CaseIterable, Identifiable {
    case activity, hot, mine, followUps
    var id: String { rawValue }
    var title: String {
        switch self {
        case .activity: "New Activity"
        case .hot: "Hot Leads"
        case .mine: "My Leads"
        case .followUps: "Follow-ups"
        }
    }
    var symbol: String {
        switch self {
        case .activity: "bell"
        case .hot: "flame"
        case .mine: "person.2"
        case .followUps: "calendar"
        }
    }
}

enum SalesSheet: Identifiable {
    case account, notifications
    case note(UUID), status(UUID), followUp(UUID), callOutcome(UUID)
    case email(UUID), text(UUID)

    var id: String {
        switch self {
        case .account: "account"
        case .notifications: "notifications"
        case .note(let id): "note-\(id)"
        case .status(let id): "status-\(id)"
        case .followUp(let id): "follow-up-\(id)"
        case .callOutcome(let id): "call-\(id)"
        case .email(let id): "email-\(id)"
        case .text(let id): "text-\(id)"
        }
    }
}
