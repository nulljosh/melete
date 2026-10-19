import SwiftUI

enum SidebarItem: String, CaseIterable, Identifiable {
    case feed = "Feed"
    case create = "Create"
    case profile = "Profile"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .feed: return "flame"
        case .create: return "plus.circle"
        case .profile: return "person.circle"
        }
    }
}

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedItem: SidebarItem = .feed
    // ponytail: `-detailOnly` launch arg hides the sidebar for landing-page screenshots
    @State private var columns: NavigationSplitViewVisibility = ProcessInfo.processInfo.arguments.contains("-detailOnly") ? .detailOnly : .all

    var body: some View {
        @Bindable var appState = appState
        NavigationSplitView(columnVisibility: $columns) {
            List(SidebarItem.allCases, selection: $selectedItem) { item in
                Label(item.rawValue, systemImage: item.icon)
                    .tag(item)
            }
            .navigationSplitViewColumnWidth(min: 160, ideal: 180, max: 220)
            .listStyle(.sidebar)
        } detail: {
            ZStack(alignment: .top) {
                switch selectedItem {
                case .feed:
                    FeedView()
                case .create:
                    CreateView(selectedItem: $selectedItem)
                case .profile:
                    ProfileView()
                }

                if appState.errorBanner != nil {
                    ErrorBanner()
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.spring(duration: 0.3), value: appState.errorBanner != nil)
            // The detail column had no minimum, so it was the pane that gave way
            // when space ran short -- the sidebar kept its 160 and the content
            // disappeared entirely.
            .frame(minWidth: 640, minHeight: 480)
        }
        .sheet(isPresented: $appState.showAuth) {
            AuthSheet()
                .environment(appState)
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToCreate)) { _ in
            if appState.isLoggedIn {
                selectedItem = .create
            } else {
                appState.showAuth = true
            }
        }
    }
}

// MARK: - Error Banner

struct ErrorBanner: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        if let msg = appState.errorBanner {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.white)
                Text(msg)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Spacer()
                Button {
                    appState.dismissError()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption2.bold())
                        .foregroundStyle(.white.opacity(0.8))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.red.opacity(0.9), in: RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 16)
            .padding(.top, 4)
        }
    }
}

// MARK: - Color Extension

extension Color {
    // ponytail: old name kept, value is the lily-pad green accent (#4d7c45 light, #8fc286 dark)
    static let sparkBlue = Color(nsColor: NSColor(name: nil) { a in
        a.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? NSColor(srgbRed: 0.561, green: 0.761, blue: 0.525, alpha: 1) : NSColor(srgbRed: 0.302, green: 0.486, blue: 0.271, alpha: 1)
    })
    static let bulb = sparkBlue
    static let paper = dynamic(light: (0.980, 0.980, 0.973), dark: (0.110, 0.102, 0.090))
    static let card = dynamic(light: (1, 1, 1), dark: (0.149, 0.137, 0.122))
    static let hairline = dynamic(light: (0.894, 0.886, 0.863), dark: (0.208, 0.192, 0.169))

    private static func dynamic(light: (Double, Double, Double), dark: (Double, Double, Double)) -> Color {
        Color(nsColor: NSColor(name: nil) { a in
            let c = a.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? dark : light
            return NSColor(srgbRed: c.0, green: c.1, blue: c.2, alpha: 1)
        })
    }
    static let onAccent = Color(nsColor: NSColor(name: nil) { a in
        a.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? NSColor(srgbRed: 0.11, green: 0.10, blue: 0.09, alpha: 1) : .white
    })

    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}

// The primary action everywhere: flat lily-pad green, same as iOS and the landing.
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(Color.onAccent)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.bulb.opacity(isEnabled ? 1 : 0.4), in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

// MARK: - Category Badge

struct CategoryBadge: View {
    let category: String

    var body: some View {
        Text(category)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.sparkBlue.opacity(0.15), in: Capsule())
            .foregroundStyle(Color.sparkBlue)
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
