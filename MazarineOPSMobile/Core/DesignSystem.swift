import SwiftUI

enum Brand {
    static let blue = Color(red: 0, green: 159 / 255, blue: 228 / 255)
    static let magenta = Color(red: 230 / 255, green: 0, blue: 126 / 255)
    static let yellow = Color(red: 225 / 255, green: 214 / 255, blue: 62 / 255)
    static let secondary = Color(white: 184 / 255)
    static let border = Color(white: 56 / 255)
    static let card = Color(white: 0.045)
    static let green = Color(red: 0.2, green: 0.9, blue: 0.35)
    static let purple = Color(red: 0.7, green: 0.35, blue: 1)

    static func heading(_ size: CGFloat = 24, relativeTo style: Font.TextStyle = .title2) -> Font {
        .custom("Manrope-Bold", size: size, relativeTo: style)
    }

    static func body(_ size: CGFloat = 15, relativeTo style: Font.TextStyle = .body) -> Font {
        .custom("AvenirNext-Regular", size: size, relativeTo: style)
    }

    static func accent(_ kind: ActivityKind) -> Color {
        switch kind {
        case .becameHot: magenta
        case .submitted, .quoteRequested, .statusChanged: green
        case .newLead, .assigned, .reassigned: purple
        case .followUpDue, .followUpScheduled: yellow
        default: blue
        }
    }

    static func temperature(_ value: LeadTemperature) -> Color {
        switch value {
        case .hot: magenta
        case .warm: yellow
        case .cold: blue
        }
    }
}

struct BrandHeader: View {
    @Environment(DemoStore.self) private var store

    var body: some View {
        HStack(spacing: 10) {
            Image("MZLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 65, height: 34)
                .accessibilityLabel("MAZARINE")
            Rectangle().fill(Brand.border).frame(width: 1, height: 25)
            Text("OPS").font(Brand.heading(21))
            Spacer()
            Button { store.sheet = .notifications } label: {
                Image(systemName: "bell")
                    .font(.title3)
                    .overlay(alignment: .topTrailing) {
                        if store.unreadCount > 0 {
                            Circle().fill(Brand.magenta).frame(width: 8, height: 8).offset(x: 4, y: -3)
                        }
                    }
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Notifications, \(store.unreadCount) unread")
            .accessibilityIdentifier("notifications")
            Button { store.sheet = .account } label: {
                Image(systemName: "person.crop.circle.fill")
                    .font(.title2).frame(width: 44, height: 44)
            }
            .accessibilityLabel("Account")
            .accessibilityIdentifier("account")
        }
        .foregroundStyle(.white)
    }
}

struct DemoBanner: View {
    var body: some View {
        Label("DEMO · Sample data only · Not connected to OPS", systemImage: "testtube.2")
            .font(Brand.body(11, relativeTo: .caption))
            .foregroundStyle(Brand.yellow)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 7)
            .accessibilityIdentifier("demo-banner")
    }
}

struct Card<Content: View>: View {
    let title: String
    let symbol: String
    var accent = Brand.blue
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: symbol)
                .font(Brand.heading(17, relativeTo: .headline))
                .labelStyle(CardLabelStyle(accent: accent))
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Brand.card, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Brand.border))
    }
}

private struct CardLabelStyle: LabelStyle {
    let accent: Color
    func makeBody(configuration: LabelStyleConfiguration) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            configuration.icon.foregroundStyle(accent)
            configuration.title.foregroundStyle(.white)
        }
    }
}

struct TemperatureBadge: View {
    let temperature: LeadTemperature
    var body: some View {
        Text(temperature.title)
            .font(Brand.body(12, relativeTo: .caption).weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(Brand.temperature(temperature).opacity(0.15), in: Capsule())
            .overlay(Capsule().stroke(Brand.temperature(temperature)))
    }
}

struct ActionTile: View {
    let title: String
    let symbol: String
    var accent = Brand.blue
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 7) {
                Image(systemName: symbol).font(.title3).foregroundStyle(accent)
                Text(title).font(Brand.body(12, relativeTo: .caption)).foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 65)
            .background(Color(white: 0.09), in: RoundedRectangle(cornerRadius: 13))
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(Brand.border))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct ActivityRow: View {
    let activity: LeadActivity
    var compact = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: activity.kind.symbol)
                .font(.system(size: compact ? 17 : 23))
                .foregroundStyle(Brand.accent(activity.kind))
                .frame(width: compact ? 30 : 46, height: compact ? 34 : 48)
                .background(Brand.accent(activity.kind).opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.kind.title).font(Brand.body(16, relativeTo: .headline).weight(.bold)).foregroundStyle(.white)
                Text(activity.detail).font(Brand.body(13, relativeTo: .subheadline)).foregroundStyle(Brand.secondary)
                Text(activity.occurredAt, style: .relative)
                    .font(Brand.body(11, relativeTo: .caption)).foregroundStyle(Brand.secondary)
            }
            Spacer(minLength: 0)
            if activity.unread {
                Circle().fill(Brand.blue).frame(width: 6, height: 6).padding(.top, 8)
                    .accessibilityLabel("Unread")
            }
            if !compact { Image(systemName: "chevron.right").foregroundStyle(Brand.secondary).padding(.top, 10) }
        }
        .padding(.vertical, compact ? 4 : 12)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

struct PrimaryButton: ButtonStyle {
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .font(Brand.body(16).weight(.bold))
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(Brand.blue.opacity(configuration.isPressed ? 0.75 : 1), in: RoundedRectangle(cornerRadius: 14))
    }
}
