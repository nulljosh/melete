import SwiftUI

/// First-launch tour. Not slides: the visitor votes on a sample idea, opens its
/// brief and brainstorms a topic, then gets asked to join. Everything here is local
/// sample data, so it works offline and touches no account.
/// Reset in the simulator with `defaults delete com.heyitsmejosh.spark tutorial_done`.
struct TutorialView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let onDone: () -> Void

    @State private var step = 0
    @State private var voted = false
    @State private var opened = false
    @State private var topic: String?
    @State private var shownIdeas = 0
    @State private var pulse = false

    private let lastStep = 4

    var body: some View {
        VStack(spacing: 0) {
            header
            Spacer(minLength: 16)
            stage
                .frame(maxWidth: 400)
                .padding(.horizontal, 24)
            Spacer(minLength: 16)
            caption
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
            actions
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
        }
        .background(Color.paper.ignoresSafeArea())
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) { pulse = true }
        }
    }

    // MARK: - Pieces

    private var header: some View {
        HStack {
            HStack(spacing: 6) {
                ForEach(0...lastStep, id: \.self) { i in
                    Capsule()
                        .fill(i <= step ? Color.sparkBlue : Color.hairline)
                        .frame(width: i == step ? 24 : 8, height: 8)
                }
            }
            .animation(.spring(duration: 0.3), value: step)
            Spacer()
            if step < lastStep {
                Button("Skip") { go(to: lastStep) }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .frame(height: 48)
    }

    @ViewBuilder private var stage: some View {
        switch step {
        case 0...2: sampleCard
        case 3: brainstorm
        default: join
        }
    }

    private var sampleCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("tech")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.sparkBlue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.sparkBlue.opacity(0.12), in: Capsule())
                Spacer()
                Text("gemma")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text("Cut optimizer for electricians")
                .font(.headline)
            Text("Electricians measure leftover wire by hand and waste the offcuts. Enter the runs you need and it plans every cut.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if opened {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    Text("SPEC").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    Text("- One screen: list of runs, one Plan button\n- Cut plan with least waste per spool\n- Leave out: pricing, inventory")
                        .font(.callout)
                    Text("PLAN").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    Text("1. Runs list and spool length\n2. Greedy cut planner\n3. Share the plan as a PDF")
                        .font(.callout)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            HStack(spacing: 12) {
                Button {
                    withAnimation(.spring(duration: 0.3)) { voted.toggle() }
                    if step == 1 && voted { advanceSoon() }
                } label: {
                    Image(systemName: voted ? "arrow.up.circle.fill" : "arrow.up")
                        .font(voted ? .title3 : .body)
                        .foregroundStyle(Color.sparkBlue)
                        .contentTransition(.symbolEffect(.replace))
                        .frame(width: 44, height: 44)
                        .background {
                            if step == 1 && !voted {
                                Circle()
                                    .stroke(Color.sparkBlue.opacity(0.5), lineWidth: 2)
                                    .scaleEffect(pulse ? 1.15 : 0.85)
                            }
                        }
                }
                .buttonStyle(.plain)
                // Not .disabled: that greys the arrow once the vote is cast.
                .allowsHitTesting(step == 1)
                .accessibilityLabel("Vote up")

                Text("\(voted ? 13 : 12)")
                    .font(.headline.monospacedDigit())
                    .contentTransition(.numericText(value: voted ? 13 : 12))
                Spacer()
                if step == 2 && !opened {
                    Label("Tap to open", systemImage: "hand.tap")
                        .font(.caption)
                        .foregroundStyle(Color.sparkBlue)
                        .opacity(pulse ? 1 : 0.4)
                }
            }
        }
        .padding(16)
        .background(Color.card, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.hairline))
        .contentShape(Rectangle())
        .onTapGesture {
            guard step == 2, !opened else { return }
            withAnimation(.spring(duration: 0.4)) { opened = true }
            advanceSoon()
        }
    }

    private static let topics: [String: [String]] = [
        "Trades": ["Pipe schedule digitizer", "Soil volume from one photo", "Permit photo log for HVAC jobs"],
        "Teachers": ["Seating chart that learns who talks", "Field trip permission in one link", "Rubric to comments in a tap"],
        "Pet owners": ["Vet bill splitter for shared dogs", "Walk swap with your neighbours", "Lost cat poster from one photo"],
    ]

    private var brainstorm: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                ForEach(["Trades", "Teachers", "Pet owners"], id: \.self) { t in
                    Button(t) { pick(t) }
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 16)
                        .frame(height: 40)
                        .foregroundStyle(topic == t ? Color.onAccent : Color.sparkBlue)
                        .background(topic == t ? Color.sparkBlue : Color.sparkBlue.opacity(0.12), in: Capsule())
                        .buttonStyle(.plain)
                }
            }
            ForEach(Array((Self.topics[topic ?? ""] ?? []).prefix(shownIdeas).enumerated()), id: \.element) { _, idea in
                HStack(spacing: 12) {
                    Image(systemName: "sparkles").foregroundStyle(Color.sparkBlue)
                    Text(idea).font(.subheadline.weight(.medium))
                    Spacer()
                }
                .padding(16)
                .background(Color.card, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.hairline))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(minHeight: 260, alignment: .top)
    }

    private var join: some View {
        Image("Mark")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(height: 160)
            .foregroundStyle(Color.sparkBlue)
    }

    private var caption: some View {
        let (title, body): (String, String) = switch step {
        case 0: ("A new idea every morning", "Melete writes one at 9 each day. People drop theirs in too.")
        case 1: ("Tap the arrow", "The good ones float to the top. Tap again to take your vote back.")
        case 2: ("Open it", "Every idea gets a build brief: what to make and how, written in seconds.")
        case 3: ("Stuck? Brainstorm", "Pick a topic and it writes three ideas for you.")
        default: ("Join the pond", "Post ideas, vote, comment, and get the 9am idea.")
        }
        return VStack(spacing: 8) {
            Text(title).font(.title2.bold())
            Text(body).font(.body).foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .frame(minHeight: 96, alignment: .top)
        .id(step)
        .transition(.opacity)
    }

    @ViewBuilder private var actions: some View {
        if step == lastStep {
            VStack(spacing: 8) {
                if appState.isLoggedIn {
                    Button { onDone() } label: { Text("Start").frame(maxWidth: .infinity) }
                        .buttonStyle(PrimaryButtonStyle())
                } else {
                    Button {
                        onDone()
                        appState.showAuth = true
                    } label: { Text("Sign in or create account").frame(maxWidth: .infinity) }
                    .buttonStyle(PrimaryButtonStyle())
                    Button("Look around first") { onDone() }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(height: 44)
                }
            }
        } else {
            Button { go(to: step + 1) } label: {
                Text(nextLabel).frame(maxWidth: .infinity).contentTransition(.identity)
            }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!canAdvance)
        }
    }

    // MARK: - Flow

    private var canAdvance: Bool {
        switch step {
        case 1: voted
        case 2: opened
        case 3: shownIdeas > 0
        default: true
        }
    }

    private var nextLabel: String {
        switch step {
        case 1 where !voted: "Vote to continue"
        case 2 where !opened: "Open the idea"
        case 3 where topic == nil: "Pick a topic"
        default: "Next"
        }
    }

    private func go(to next: Int) {
        withAnimation(.spring(duration: 0.4)) { step = min(next, lastStep) }
    }

    private func advanceSoon() {
        let from = step
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            if step == from { go(to: from + 1) }
        }
    }

    private func pick(_ t: String) {
        topic = t
        shownIdeas = 0
        Task {
            for i in 1...3 {
                try? await Task.sleep(for: .seconds(reduceMotion ? 0 : 0.25))
                withAnimation(.spring(duration: 0.4)) { shownIdeas = i }
            }
        }
    }
}
