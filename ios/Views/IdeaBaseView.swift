import SwiftUI

struct IdeaBaseView: View {
    @Environment(AppState.self) private var appState
    @State private var topic = ""
    @State private var description = ""
    @State private var isSubmitting = false
    @State private var message: String?
    @State private var ideaBases: [IdeaBase] = []
    @State private var isLoadingMore = false
    @State private var reachedEnd = false

    // The Brainstorm half of Create; it lives inside Create's NavigationStack.
    var body: some View {
            Form {
                if appState.isLoggedIn {
                    Section("Brainstorm a topic") {
                        TextField("Topic", text: $topic)
                        TextField("Context (optional)", text: $description, axis: .vertical)
                            .lineLimit(2...4)
                        Button(action: submit) {
                            if isSubmitting {
                                ProgressView().frame(maxWidth: .infinity)
                            } else {
                                Text("Write Three Ideas")
                                    .frame(maxWidth: .infinity)
                                    .fontWeight(.semibold)
                            }
                        }
                        .disabled(topic.trimmingCharacters(in: .whitespaces).isEmpty || isSubmitting)
                        if let msg = message {
                            Text(msg)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if !ideaBases.isEmpty {
                Section("Recent topics") {
                        ForEach(ideaBases) { ib in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(ib.topic)
                                    .font(.subheadline.weight(.medium))
                                if let n = ib.postIds?.count, n > 0 {
                                    Text("\(n) ideas")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .onAppear {
                                if ib.id == ideaBases.last?.id { loadMore() }
                            }
                        }
                        if isLoadingMore {
                            ProgressView().frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.paper)
            .task {
                ideaBases = (try? await appState.api.fetchIdeaBases(offset: 0)) ?? []
            }
    }

    private func loadMore() {
        guard !isLoadingMore, !reachedEnd else { return }
        isLoadingMore = true
        Task {
            let more = (try? await appState.api.fetchIdeaBases(offset: ideaBases.count)) ?? []
            if more.isEmpty { reachedEnd = true } else { ideaBases.append(contentsOf: more) }
            isLoadingMore = false
        }
    }

    private func submit() {
        isSubmitting = true
        message = nil
        Task {
            do {
                _ = try await appState.api.createIdeaBase(
                    topic: topic,
                    description: description.isEmpty ? nil : description
                )
                message = "Three new ideas are in the feed."
                await appState.loadPosts()
                topic = ""
                description = ""
                ideaBases = (try? await appState.api.fetchIdeaBases(offset: 0)) ?? []
            } catch {
                message = error.localizedDescription
            }
            isSubmitting = false
        }
    }
}
