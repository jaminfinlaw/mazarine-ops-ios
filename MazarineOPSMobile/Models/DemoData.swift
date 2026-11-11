import Foundation

enum DemoData {
    static let jamesID = UUID(uuidString: "00000000-0000-4000-8000-000000000001")!
    static let robertID = UUID(uuidString: "00000000-0000-4000-8000-000000000002")!
    static let davidID = UUID(uuidString: "00000000-0000-4000-8000-000000000003")!

    static func leads(now: Date) -> [Lead] {
        [
            Lead(id: jamesID, name: "James Mitchell", email: "james@example.com", phone: nil,
                 location: "Houston, TX 77024", source: "Website", createdAt: now.addingTimeInterval(-172800),
                 salesperson: "Demo Salesperson", assignedToMe: true, timeframe: "Within 4 weeks",
                 temperature: .hot, status: .inProgress,
                 boat: Boat(name: "Liquid Plumber", make: "Valhalla", model: "41", year: "2024"),
                 configurations: [
                    Configuration(id: UUID(), model: "75 SE",
                                  options: ["Front LED Sign", "8-Piece Storage", "Inside Artwork"],
                                  total: 6690, coupon: "Sample promotion", status: "Quote requested",
                                  openedAt: now.addingTimeInterval(-420), submittedAt: now.addingTimeInterval(-1080)),
                    Configuration(id: UUID(), model: "53 E", options: ["Front LED Sign"], total: 4490,
                                  coupon: nil, status: "Saved draft", openedAt: now.addingTimeInterval(-86400), submittedAt: nil)
                 ],
                 notes: [
                    LeadNote(id: UUID(), body: "Interested in 75 SE with custom artwork. Follow up early next week.",
                             author: "Demo Salesperson", createdAt: now.addingTimeInterval(-86400)),
                    LeadNote(id: UUID(), body: "Asked about delivery timeframe.", author: "Demo Salesperson",
                             createdAt: now.addingTimeInterval(-172800))
                 ],
                 followUps: [FollowUp(id: UUID(), dueAt: now.addingTimeInterval(3600), note: "Discuss artwork", reminder: true)]),
            Lead(id: robertID, name: "Robert Wilson", email: "robert@example.com", phone: nil,
                 location: "Fort Lauderdale, FL", source: "Boat Show", createdAt: now.addingTimeInterval(-259200),
                 salesperson: "Demo Salesperson", assignedToMe: true, timeframe: nil, temperature: .warm,
                 status: .responded, boat: nil,
                 configurations: [Configuration(id: UUID(), model: "53 E", options: ["Storage System"],
                                                 total: 4290, coupon: nil, status: "Submitted",
                                                 openedAt: now.addingTimeInterval(-7200), submittedAt: now.addingTimeInterval(-1080))],
                 notes: [], followUps: [FollowUp(id: UUID(), dueAt: now.addingTimeInterval(-1800), note: "Review quote", reminder: false)]),
            Lead(id: davidID, name: "David Thompson", email: "david@example.com", phone: nil,
                 location: nil, source: "Referral", createdAt: now.addingTimeInterval(-2040),
                 salesperson: "Demo Salesperson", assignedToMe: true, timeframe: nil, temperature: .cold,
                 status: .new, boat: nil,
                 configurations: [Configuration(id: UUID(), model: nil, options: [], total: nil, coupon: nil,
                                                 status: "Opened", openedAt: now.addingTimeInterval(-600), submittedAt: nil)],
                 notes: [], followUps: [])
        ]
    }

    static func activities(now: Date) -> [LeadActivity] {
        [
            LeadActivity(id: UUID(), leadID: jamesID, kind: .becameHot, detail: "James Mitchell · 75 SE",
                         occurredAt: now.addingTimeInterval(-120), unread: true),
            LeadActivity(id: UUID(), leadID: jamesID, kind: .configuratorOpened, detail: "James Mitchell viewed his 75 SE configuration",
                         occurredAt: now.addingTimeInterval(-420), unread: true),
            LeadActivity(id: UUID(), leadID: robertID, kind: .quoteRequested, detail: "Robert Wilson submitted a quote for the 53 E",
                         occurredAt: now.addingTimeInterval(-1080), unread: true),
            LeadActivity(id: UUID(), leadID: davidID, kind: .assigned, detail: "David Thompson · No model selected",
                         occurredAt: now.addingTimeInterval(-2040), unread: true),
            LeadActivity(id: UUID(), leadID: robertID, kind: .followUpDue, detail: "Robert Wilson · Review quote",
                         occurredAt: now.addingTimeInterval(-1800), unread: true),
            LeadActivity(id: UUID(), leadID: jamesID, kind: .newLead, detail: "Lead created from website inquiry",
                         occurredAt: now.addingTimeInterval(-172800), unread: false)
        ].sorted { $0.occurredAt > $1.occurredAt }
    }
}
