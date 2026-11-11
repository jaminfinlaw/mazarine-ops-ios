import SwiftUI

struct SalesSheetView: View {
    @Environment(DemoStore.self) private var store
    let destination: SalesSheet
    let openLead: (UUID) -> Void

    @State private var text = ""
    @State private var selectedStatus = LeadStatus.new
    @State private var lostReason = ""
    @State private var date = Date.now.addingTimeInterval(86400)
    @State private var reminder = false
    @State private var callOutcome = "No answer"
    @FocusState private var noteFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Label("Demo workspace", systemImage: "testtube.2").foregroundStyle(Brand.yellow)
                    Text("Sample edits are in memory only. Nothing here changes OPS, contacts customers, or schedules real notifications.")
                        .font(Brand.body(13)).foregroundStyle(Brand.secondary)
                }
                content
            }
            .font(Brand.body(15))
            .scrollContentBackground(.hidden)
            .background(.black)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { store.sheet = nil } }
            }
        }
        .onAppear {
            if case .status(let id) = destination, let lead = store.lead(id) { selectedStatus = lead.status }
        }
    }

    @ViewBuilder private var content: some View {
        switch destination {
        case .account:
            Section("Account") {
                LabeledContent("Name", value: "Demo Salesperson")
                LabeledContent("Connection", value: "Not connected")
                Text("Secure OPS login, Keychain session storage, and optional Face ID are planned for the integration milestone.")
                    .foregroundStyle(Brand.secondary)
            }
        case .notifications:
            Section("Notification preferences") {
                Text("These preview preferences do not request push permission or register this device.")
                    .font(Brand.body(13)).foregroundStyle(Brand.secondary)
                ForEach(ActivityKind.allCases) { kind in
                    Toggle(kind.title, isOn: Binding(
                        get: { store.notificationCategories.contains(kind) },
                        set: { enabled in
                            if enabled { store.notificationCategories.insert(kind) }
                            else { store.notificationCategories.remove(kind) }
                        }
                    ))
                }
            }
            Section("Unread activity") {
                let unread = store.activities.filter(\.unread)
                if unread.isEmpty { Text("You're all caught up.").foregroundStyle(Brand.secondary) }
                ForEach(unread) { activity in
                    Button { openLead(activity.leadID) } label: { ActivityRow(activity: activity, compact: true) }
                }
            }
        case .note(let id):
            Section("Internal note") {
                TextEditor(text: $text)
                    .frame(minHeight: 150)
                    .focused($noteFocused)
                    .accessibilityLabel("Internal note")
                    .accessibilityIdentifier("note-input")
                    .defaultFocus($noteFocused, true)
                Button("Save Sample Note") {
                    store.addNote(text, to: id)
                    store.sheet = nil
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("save-note")
            }
        case .status(let id):
            Section("Lead status") {
                Picker("Status", selection: $selectedStatus) {
                    ForEach(LeadStatus.allCases) { status in Text(status.title).tag(status) }
                }
                .pickerStyle(.inline)
                if selectedStatus == .lost {
                    TextField("Lost reason (required)", text: $lostReason)
                }
                Text("Preview choices reflect manually editable OPS lifecycle statuses. Live integration will fetch allowed transitions and reasons per Lead.")
                    .font(Brand.body(12)).foregroundStyle(Brand.secondary)
                Button("Save Sample Status") {
                    store.updateStatus(selectedStatus, reason: lostReason, leadID: id)
                    store.sheet = nil
                }
                .disabled(selectedStatus == .lost && lostReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("save-status")
            }
        case .followUp(let id):
            Section("Schedule follow-up") {
                DatePicker("Date and time", selection: $date, in: Date.now..., displayedComponents: [.date, .hourAndMinute])
                TextField("Optional note", text: $text, axis: .vertical).lineLimit(3...5)
                Toggle("Reminder preference (demo only)", isOn: $reminder)
                Text("No local or push reminder is scheduled by this prototype.")
                    .font(Brand.body(12)).foregroundStyle(Brand.secondary)
                Button("Save Sample Follow-up") {
                    store.scheduleFollowUp(leadID: id, date: date, note: text, reminder: reminder)
                    store.sheet = nil
                }
                .disabled(date <= .now)
                .accessibilityIdentifier("save-follow-up")
            }
        case .callOutcome(let id):
            Section("Call preview") {
                Text("No call will be placed. Sample Leads have no callable phone number.")
                    .foregroundStyle(Brand.secondary)
                Picker("Outcome", selection: $callOutcome) {
                    ForEach(["No answer", "Left voicemail", "Spoke with customer"], id: \.self) { Text($0) }
                }
                Button("Save Sample Outcome") {
                    store.logCall(leadID: id, outcome: callOutcome)
                    store.sheet = nil
                }
            }
        case .email(let id):
            Section("Email preview") {
                LabeledContent("To", value: store.lead(id)?.email ?? "Not provided")
                Text("Native Mail composition will be enabled for authorized OPS contacts during integration. No email will be sent from sample data.")
                    .foregroundStyle(Brand.secondary)
            }
        case .text:
            Section("Messages preview") {
                Text("Native Messages composition will be enabled for authorized OPS phone numbers during integration. No text will be sent from sample data.")
                    .foregroundStyle(Brand.secondary)
            }
        }
    }

    private var title: String {
        switch destination {
        case .account: "Account"
        case .notifications: "Notifications"
        case .note: "Add Note"
        case .status: "Update Lead Status"
        case .followUp: "Follow-up"
        case .callOutcome: "Call Outcome"
        case .email: "Email"
        case .text: "Text"
        }
    }
}
