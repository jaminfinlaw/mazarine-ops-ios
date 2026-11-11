import SwiftUI

struct LeadsActivityView: View {
    @Environment(DemoStore.self) private var store
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        @Bindable var store = store
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BrandHeader()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Leads & Activity").font(Brand.heading(30, relativeTo: .largeTitle))
                    Text("Real-time notifications and quick management")
                        .font(Brand.body(14, relativeTo: .subheadline)).foregroundStyle(Brand.secondary)
                    DemoBanner()
                }
                summary
                HStack {
                    Image(systemName: "magnifyingglass").foregroundStyle(Brand.secondary)
                    TextField("Search leads", text: $store.search)
                        .font(Brand.body(15)).autocorrectionDisabled()
                        .accessibilityIdentifier("lead-search")
                }
                .padding(12)
                .background(Brand.card, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Brand.border))
                if store.filter == .activity {
                    if store.filteredActivities.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 0) {
                            ForEach(store.filteredActivities) { activity in
                                NavigationLink(value: activity.leadID) { ActivityRow(activity: activity) }
                                    .buttonStyle(.plain)
                                Divider().overlay(Brand.border)
                            }
                        }
                    }
                    if let id = store.selectedLeadID, let lead = store.lead(id) {
                        LeadQuickCard(lead: lead)
                    }
                } else {
                    if store.filteredLeads.isEmpty { emptyState }
                    ForEach(store.filteredLeads) { lead in
                        VStack(spacing: 10) {
                            Button {
                                store.selectedLeadID = store.selectedLeadID == lead.id ? nil : lead.id
                            } label: {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(lead.name).font(Brand.heading(19, relativeTo: .headline))
                                        Text("\(lead.model) · \(lead.status.title)")
                                            .font(Brand.body(13)).foregroundStyle(Brand.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: store.selectedLeadID == lead.id ? "chevron.up" : "chevron.down")
                                }
                                .foregroundStyle(.white).padding(14).contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("expand-\(lead.id.uuidString)")
                            if store.selectedLeadID == lead.id { LeadQuickCard(lead: lead) }
                        }
                        .background(Brand.card, in: RoundedRectangle(cornerRadius: 14))
                    }
                }
                Text("Preview workspace · Refreshed \(store.lastRefreshedAt.formatted(date: .omitted, time: .shortened))")
                    .font(Brand.body(11, relativeTo: .caption)).foregroundStyle(Brand.secondary)
            }
            .padding(.horizontal, 20).padding(.bottom, 28)
        }
        .background(.black)
        .toolbar(.hidden, for: .navigationBar)
        .refreshable { await store.refresh() }
    }

    @ViewBuilder private var summary: some View {
        if dynamicTypeSize.isAccessibilitySize {
            ScrollView(.horizontal) { summaryCards.frame(minWidth: 620) }.scrollIndicators(.hidden)
        } else {
            summaryCards
        }
    }

    private var summaryCards: some View {
        HStack(spacing: 7) {
            ForEach(DashboardFilter.allCases) { filter in
                Button { store.filter = filter } label: {
                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: filter.symbol)
                                .foregroundStyle(filter == .hot ? Brand.magenta : filter == .activity ? Brand.blue : .white)
                            Text("\(store.count(filter))").fontWeight(.bold).foregroundStyle(.white)
                        }
                        .font(Brand.body(19, relativeTo: .headline))
                        Text(filter.title).font(Brand.body(10, relativeTo: .caption)).foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, minHeight: 76)
                    .background(store.filter == filter ? Brand.blue.opacity(0.08) : Brand.card, in: RoundedRectangle(cornerRadius: 13))
                    .overlay(RoundedRectangle(cornerRadius: 13).stroke(store.filter == filter ? Brand.blue : Brand.border))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(filter.title), \(store.count(filter))")
                .accessibilityAddTraits(store.filter == filter ? .isSelected : [])
                .accessibilityIdentifier("filter-\(filter.rawValue)")
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView("No matching sample leads", systemImage: "magnifyingglass",
                               description: Text("Try a different filter or search."))
    }
}

struct LeadQuickCard: View {
    @Environment(DemoStore.self) private var store
    let lead: Lead

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            NavigationLink(value: lead.id) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(lead.name).font(Brand.heading(21, relativeTo: .headline)).foregroundStyle(.white)
                        Text("\(lead.model) · \(lead.status.title)").font(Brand.body(13)).foregroundStyle(Brand.secondary)
                    }
                    Spacer()
                    TemperatureBadge(temperature: lead.temperature)
                    Image(systemName: "chevron.right").foregroundStyle(.white)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("open-lead-\(lead.id.uuidString)")
            HStack(spacing: 7) {
                ActionTile(title: "Call", symbol: "phone") { store.sheet = .callOutcome(lead.id) }
                ActionTile(title: "Email", symbol: "envelope") { store.sheet = .email(lead.id) }
                ActionTile(title: "Note", symbol: "bubble.left") { store.sheet = .note(lead.id) }
                ActionTile(title: "Update", symbol: "checkmark.circle") { store.sheet = .status(lead.id) }
            }
        }
        .padding(14)
        .background(Brand.card, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Brand.border))
        .overlay(alignment: .leading) {
            UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 16)
                .fill(Brand.temperature(lead.temperature)).frame(width: 5)
        }
    }
}
