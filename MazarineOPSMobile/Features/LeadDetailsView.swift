import SwiftUI
import UIKit

struct LeadDetailsView: View {
    @Environment(DemoStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let leadID: UUID
    @State private var showAllHistory = false
    @State private var showAllNotes = false

    var body: some View {
        Group {
            if let lead = store.lead(leadID) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        BrandHeader()
                        Button { dismiss() } label: {
                            Label("Leads & Activity", systemImage: "chevron.left").font(Brand.body(13))
                        }
                        .foregroundStyle(.white).frame(minHeight: 44)
                        .accessibilityIdentifier("back-to-dashboard")
                        leadHeader(lead)
                        HStack(spacing: 7) {
                            ActionTile(title: "Call", symbol: "phone") { store.sheet = .callOutcome(leadID) }
                            ActionTile(title: "Email", symbol: "envelope") { store.sheet = .email(leadID) }
                            ActionTile(title: "Text", symbol: "bubble.left") { store.sheet = .text(leadID) }
                            ActionTile(title: "Follow-up", symbol: "calendar") { store.sheet = .followUp(leadID) }
                        }
                        contactCard(lead)
                        if let boat = lead.boat {
                            Card(title: "Boat Information", symbol: "sailboat") {
                                detail("Boat Name", boat.name)
                                detail("Make", boat.make)
                                detail("Model", boat.model)
                                detail("Year", boat.year)
                                Text("No boat image supplied for this sample Lead.")
                                    .font(Brand.body(12)).foregroundStyle(Brand.secondary)
                            }
                        }
                        configurationCard(lead)
                        Card(title: "Activity History", symbol: "waveform.path.ecg", accent: Brand.magenta) {
                            let history = store.history(leadID)
                            ForEach(showAllHistory ? history : Array(history.prefix(4))) { activity in
                                ActivityRow(activity: activity, compact: true)
                            }
                            if history.count > 4 {
                                Button(showAllHistory ? "Show recent activity" : "Show older activity") { showAllHistory.toggle() }
                                    .font(Brand.body(14)).frame(minHeight: 44)
                            }
                        }
                        notesCard(lead)
                        if !lead.followUps.isEmpty { followUpCard(lead) }
                        Button { store.sheet = .status(leadID) } label: {
                            Label("UPDATE LEAD STATUS", systemImage: "checkmark.circle")
                        }
                        .buttonStyle(PrimaryButton())
                        .accessibilityIdentifier("update-lead-status")
                    }
                    .padding(.horizontal, 20).padding(.bottom, 30)
                }
                .refreshable { await store.refresh() }
            } else {
                ContentUnavailableView("Lead unavailable", systemImage: "person.crop.circle.badge.exclamationmark",
                                       description: Text("Return to Leads & Activity and refresh."))
            }
        }
        .background(.black)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { store.markRead(leadID) }
    }

    private func leadHeader(_ lead: Lead) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            ViewThatFits(in: .horizontal) {
                HStack {
                    Text(lead.name).font(Brand.heading(28, relativeTo: .title))
                    Spacer()
                    TemperatureBadge(temperature: lead.temperature)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(lead.name).font(Brand.heading(28, relativeTo: .title))
                    TemperatureBadge(temperature: lead.temperature)
                }
            }
            Text("\(lead.model) · \(lead.status.title)").foregroundStyle(Brand.secondary)
            Text("Assigned to \(lead.salesperson)").font(Brand.body(12)).foregroundStyle(Brand.secondary)
            if let last = store.history(leadID).first {
                Text("Last activity \(last.occurredAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(Brand.body(12)).foregroundStyle(Brand.secondary)
            }
            DemoBanner()
        }
        .font(Brand.body(14))
    }

    private func contactCard(_ lead: Lead) -> some View {
        Card(title: "Lead Information", symbol: "person.fill") {
            if let email = lead.email { copyRow("Email", email, symbol: "envelope", action: { store.sheet = .email(leadID) }) }
            if let phone = lead.phone { copyRow("Phone", phone, symbol: "phone", action: { store.sheet = .callOutcome(leadID) }) }
            if let location = lead.location { copyRow("Location", location, symbol: "mappin.and.ellipse") }
            DisclosureGroup("More lead information") {
                VStack(spacing: 10) {
                    detail("Source", lead.source)
                    detail("Created", lead.createdAt.formatted(date: .abbreviated, time: .omitted))
                    detail("Salesperson", lead.salesperson)
                    if let timeframe = lead.timeframe { detail("Purchase timeframe", timeframe) }
                    detail("Status", lead.status.title)
                }
                .padding(.top, 10)
            }
            .font(Brand.body(14)).foregroundStyle(.white)
        }
    }

    private func configurationCard(_ lead: Lead) -> some View {
        Card(title: "Configuration", symbol: "slider.horizontal.3") {
            if let configuration = lead.configurations.first {
                Text(configuration.summary).font(Brand.body(16).weight(.semibold))
                if !configuration.options.isEmpty { detail("Options", configuration.options.joined(separator: ", ")) }
                detail("Status", configuration.status)
                DisclosureGroup("View Configuration Details") {
                    configurationDetails(configuration)
                }
                .font(Brand.body(14))
                if lead.configurations.count > 1 {
                    DisclosureGroup("Earlier configurations (\(lead.configurations.count - 1))") {
                        ForEach(lead.configurations.dropFirst()) { configuration in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(configuration.summary).font(Brand.body(16).weight(.semibold))
                                configurationDetails(configuration)
                            }.padding(.vertical, 8)
                        }
                    }.font(Brand.body(14))
                }
                HStack {
                    Button("Copy Configurator Link", systemImage: "doc.on.doc") {
                        store.notice = "Sample Lead has no live configurator URL. No link was copied."
                    }
                    Button("Share", systemImage: "square.and.arrow.up") {
                        store.notice = "Sharing will use the authorized existing OPS link after integration."
                    }
                }
                .font(Brand.body(12)).frame(minHeight: 44)
            } else {
                Text("No configuration recorded.").foregroundStyle(Brand.secondary)
            }
        }
    }

    private func configurationDetails(_ configuration: Configuration) -> some View {
        VStack(spacing: 9) {
            if let amount = configuration.total {
                detail("Estimated total", amount.formatted(.currency(code: "USD")))
            }
            if let coupon = configuration.coupon { detail("Coupon", coupon) }
            if let opened = configuration.openedAt { detail("Last opened", opened.formatted(date: .abbreviated, time: .shortened)) }
            if let submitted = configuration.submittedAt { detail("Submitted", submitted.formatted(date: .abbreviated, time: .shortened)) }
            if configuration.model == nil {
                Text("An open is recorded, but no model or options have been saved.")
                    .font(Brand.body(13)).foregroundStyle(Brand.secondary)
            }
        }.padding(.top, 10)
    }

    private func notesCard(_ lead: Lead) -> some View {
        Card(title: "Notes (\(lead.notes.count))", symbol: "note.text", accent: Brand.green) {
            ForEach(showAllNotes ? lead.notes : Array(lead.notes.prefix(1))) { note in
                VStack(alignment: .leading, spacing: 6) {
                    Text(note.body).font(Brand.body(14))
                    Text("\(note.author) · \(note.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(Brand.body(11, relativeTo: .caption)).foregroundStyle(Brand.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading).padding(10)
                .background(Color(white: 0.1), in: RoundedRectangle(cornerRadius: 10))
            }
            HStack {
                Button("Add Note", systemImage: "plus") { store.sheet = .note(leadID) }
                    .accessibilityIdentifier("add-note")
                Spacer()
                if lead.notes.count > 1 {
                    Button(showAllNotes ? "Show recent" : "Show all") { showAllNotes.toggle() }
                }
            }.font(Brand.body(14)).frame(minHeight: 44)
        }
    }

    private func followUpCard(_ lead: Lead) -> some View {
        Card(title: "Follow-ups", symbol: "calendar", accent: Brand.yellow) {
            ForEach(lead.followUps) { followUp in
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(followUp.dueAt.formatted(date: .abbreviated, time: .shortened))
                        if !followUp.note.isEmpty { Text(followUp.note).foregroundStyle(Brand.secondary) }
                        Text(followUp.completed ? "Completed" : followUp.reminder ? "Sample reminder selected" : "No reminder")
                            .font(Brand.body(11)).foregroundStyle(followUp.completed ? Brand.green : Brand.secondary)
                    }.font(Brand.body(13))
                    Spacer()
                    if !followUp.completed {
                        Button("Complete") { store.completeFollowUp(leadID: leadID, followUpID: followUp.id) }
                            .font(Brand.body(12)).frame(minHeight: 44)
                    }
                }
            }
        }
    }

    private func detail(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text("\(title):").foregroundStyle(Brand.secondary)
            Spacer(minLength: 10)
            Text(value).multilineTextAlignment(.trailing)
        }.font(Brand.body(13))
    }

    private func copyRow(_ title: String, _ value: String, symbol: String, action: (() -> Void)? = nil) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol).frame(width: 20).foregroundStyle(Brand.secondary)
            if let action {
                Button(value, action: action).foregroundStyle(.white).multilineTextAlignment(.leading)
            } else {
                Text(value)
            }
            Spacer(minLength: 0)
            Button {
                UIPasteboard.general.string = value
                store.notice = "\(title) copied."
            } label: { Image(systemName: "doc.on.doc").frame(width: 44, height: 44) }
                .foregroundStyle(Brand.secondary)
                .accessibilityLabel("Copy \(title.lowercased())")
        }.font(Brand.body(13))
    }
}
