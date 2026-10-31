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

    // Launch only restores an existing grant. New permission requests belong to
    // the settings toggle, where they cannot precede the app's first frame.
    static func scheduleIfAuthorized() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }
        await schedule()
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
            // Never request permission during launch; only restore an existing schedule.
            .task(id: appState.isLoggedIn && tutorialDone && !showSplash) {
                if appState.isLoggedIn, tutorialDone, !showSplash, UserDefaults.standard.object(forKey: "daily_idea") as? Bool ?? true { await DailyIdea.scheduleIfAuthorized() }
            }
        }
    }
}

struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var lampIn = false
    @State private var lit = false
    @State private var titleIn = false

    private let ink = Color(hex: "eef3ea")

    var body: some View {
        ZStack {
            Color(hex: "1f2b1d").ignoresSafeArea()

            VStack(spacing: 24) {
                // The mark in two pieces on one 200 pt canvas: the lamp settles,
                // then its flame catches and glows.
                ZStack {
                    Image("SplashLamp")
                        .resizable()
                        .foregroundStyle(ink)
                        .opacity(lampIn ? 1 : 0)
                        .offset(y: lampIn ? 0 : 12)
                    Image("SplashFlame")
                        .resizable()
                        .foregroundStyle(ink)
                        .shadow(color: ink.opacity(lit ? 0.9 : 0), radius: lit ? 18 : 0)
                        .scaleEffect(lit ? 1 : 0.2, anchor: UnitPoint(x: 0.76, y: 0.55))
                        .opacity(lit ? 1 : 0)
                }
                .frame(width: 200, height: 200)

                VStack(spacing: 8) {
                    Text("Melete")
                        .font(.system(size: 40, weight: .regular, design: .serif))
                        .foregroundStyle(ink)
                    Text("Ideas worth thinking about.")
                        .font(.subheadline)
                        .foregroundStyle(ink.opacity(0.65))
                }
                .opacity(titleIn ? 1 : 0)
                .offset(y: titleIn ? 0 : 8)
            }
        }
        .task {
            if reduceMotion {
                lampIn = true; lit = true; titleIn = true
                return
            }
            withAnimation(.easeOut(duration: 0.4)) { lampIn = true }
            try? await Task.sleep(for: .seconds(0.35))
            withAnimation(.spring(response: 0.5, dampingFraction: 0.55)) { lit = true }
            try? await Task.sleep(for: .seconds(0.2))
            withAnimation(.easeOut(duration: 0.5)) { titleIn = true }
        }
    }
}
