import SwiftUI
import UserNotifications

// Daily 9am local nudge, matches the cron that posts the morning idea.
enum DailyIdea {
    static func schedule() async {
        let center = UNUserNotificationCenter.current()
        guard (try? await center.requestAuthorization(options: [.alert, .sound])) == true else { return }
        let content = UNMutableNotificationContent()
        content.title = "Today's idea just flew in"
        content.body = "A new one is in the jar."
        let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: 9), repeats: true)
        try? await center.add(UNNotificationRequest(identifier: "daily-idea", content: content, trigger: trigger))
    }

    static func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-idea"])
    }
}

@main
struct SparkApp: App {
    @State private var appState = AppState()
    @State private var showSplash = true
    // Screenshot runs skip the tour so every shot lands on the real app.
    @AppStorage("tutorial_done") private var tutorialDone = CommandLine.arguments.contains("UITEST_SNAPSHOT")

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environment(appState)
                    .overlay { WhatsNewSheet() }

                if !tutorialDone {
                    TutorialView { withAnimation(.easeInOut(duration: 0.4)) { tutorialDone = true } }
                        .environment(appState)
                        .transition(.opacity)
                }

                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .animation(.easeInOut(duration: 0.8), value: showSplash)
            .task {
                // Someone already signed in has used the app; the tour is for newcomers.
                if appState.isLoggedIn { tutorialDone = true }
                try? await Task.sleep(for: .seconds(1.8))
                showSplash = false
            }
            // The keychain outlives a reinstall, so a fresh install can already be signed in.
            // Wait for the splash so the prompt lands on the feed, not on a blank screen.
            .task(id: appState.isLoggedIn && tutorialDone && !showSplash) {
                if appState.isLoggedIn, tutorialDone, !showSplash, UserDefaults.standard.object(forKey: "daily_idea") as? Bool ?? true { await DailyIdea.schedule() }
            }
        }
    }
}

struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var padIn = false
    @State private var landed = false
    @State private var ripple = false
    @State private var titleIn = false

    private let ink = Color(hex: "f3ede0")

    var body: some View {
        ZStack {
            Color(hex: "1c1a17").ignoresSafeArea()

            VStack(spacing: 24) {
                // The mark in two pieces on one 200 pt canvas: a brain drops onto
                // the lily pad and the pond ripples out from where it lands.
                ZStack {
                    ForEach(0..<2) { i in
                        Ellipse()
                            .stroke(Color.bulb.opacity(0.7), lineWidth: 2)
                            .frame(width: 160, height: 49)
                            .scaleEffect(ripple ? 1.7 + CGFloat(i) * 0.5 : 1)
                            .opacity(ripple ? 0 : (landed ? 0.8 : 0))
                            .animation(.easeOut(duration: 1.1).delay(Double(i) * 0.18), value: ripple)
                            .offset(y: 35)
                    }
                    Image("SplashPad")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .opacity(padIn ? 1 : 0)
                        .scaleEffect(padIn ? 1 : 0.92)
                    Image("SplashBrain")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .offset(y: landed ? 0 : -140)
                        .opacity(landed ? 1 : 0)
                }
                .frame(width: 200, height: 200)

                VStack(spacing: 8) {
                    Text("Melete")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(ink)
                    Text("Drop an idea in. Watch it ripple.")
                        .font(.subheadline)
                        .foregroundStyle(ink.opacity(0.6))
                }
                .opacity(titleIn ? 1 : 0)
                .offset(y: titleIn ? 0 : 8)
            }
        }
        .task {
            if reduceMotion {
                padIn = true; landed = true; titleIn = true
                return
            }
            withAnimation(.easeOut(duration: 0.35)) { padIn = true }
            try? await Task.sleep(for: .seconds(0.2))
            withAnimation(.spring(response: 0.45, dampingFraction: 0.62)) { landed = true }
            try? await Task.sleep(for: .seconds(0.3))
            ripple = true
            withAnimation(.easeOut(duration: 0.5)) { titleIn = true }
        }
    }
}
