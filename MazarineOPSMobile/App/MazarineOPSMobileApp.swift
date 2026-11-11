import SwiftUI

@main
struct MazarineOPSMobileApp: App {
    @State private var store = DemoStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            AppRoot()
                .environment(store)
                .preferredColorScheme(.dark)
                .tint(Brand.blue)
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active { Task { await store.refresh() } }
                }
        }
    }
}

struct AppRoot: View {
    @Environment(DemoStore.self) private var store
    @State private var path: [UUID] = []

    var body: some View {
        @Bindable var store = store
        NavigationStack(path: $path) {
            LeadsActivityView()
                .navigationDestination(for: UUID.self) { leadID in
                    LeadDetailsView(leadID: leadID)
                }
        }
        .sheet(item: $store.sheet) { destination in
            SalesSheetView(destination: destination) { leadID in
                store.sheet = nil
                path = [leadID]
            }
            .environment(store)
            .preferredColorScheme(.dark)
            .presentationDragIndicator(.visible)
        }
        .overlay(alignment: .bottom) {
            if let notice = store.notice {
                HStack(alignment: .top) {
                    Text(notice).font(Brand.body(13))
                    Spacer()
                    Button { store.notice = nil } label: {
                        Image(systemName: "xmark").frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Dismiss confirmation")
                }
                .foregroundStyle(.white)
                .padding(12)
                .background(Brand.border, in: RoundedRectangle(cornerRadius: 12))
                .padding()
                .accessibilityIdentifier("confirmation")
            }
        }
    }
}

#Preview {
    AppRoot().environment(DemoStore()).preferredColorScheme(.dark)
}
