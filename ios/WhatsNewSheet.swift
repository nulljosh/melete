import SwiftUI

private let whatsNewVersion = "3.2"
private let whatsNewRows: [(icon: String, text: String)] = [
    ("flame", "A new name: Melete, the Muse of thought. A new icon to match."),
    ("rectangle.grid.1x2", "A simpler feed: a title, a pitch and votes."),
    ("magnifyingglass", "Open any idea to see what is already on the App Store."),
    ("arrow.up.arrow.down", "One switch for New or Trending."),
]

struct WhatsNewSheet: View {
    @AppStorage("whats_new_seen_version") private var seenVersion = ""
    @AppStorage("tutorial_done") private var tutorialDone = false
    @State private var isPresented = false

    var body: some View {
        Color.clear
            .task {
                // Wait for the splash to fade before showing anything.
                try? await Task.sleep(for: .seconds(1.6))
                // Newcomers get the tour instead; this sheet is for people updating.
                if !tutorialDone { seenVersion = whatsNewVersion }
                isPresented = seenVersion != whatsNewVersion
            }
            .sheet(isPresented: $isPresented) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("New in Melete \(whatsNewVersion)")
                        .font(.title2.bold())

                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(whatsNewRows, id: \.text) { row in
                            HStack(alignment: .firstTextBaseline, spacing: 14) {
                                Image(systemName: row.icon)
                                    .foregroundStyle(Color.sparkBlue)
                                    .frame(width: 22)
                                Text(row.text)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)

                    Button {
                        seenVersion = whatsNewVersion
                        isPresented = false
                    } label: {
                        Text("Got it")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .controlSize(.large)
                    .tint(.sparkBlue)
                }
                .padding(.horizontal, 28)
                .padding(.top, 36)
                .padding(.bottom, 24)
                .frame(maxHeight: .infinity, alignment: .top)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
    }
}
