import SwiftUI

struct IdeaBaseView: View {
    @Environment(AppState.self) private var appState

    @State private var ideaBases: [IdeaBase] = []
    // -brainstorm (store shots) types a sample topic in, so the form shows what it is for.
    @State private var topic = ProcessInfo.processInfo.arguments.contains("-brainstorm") ? "Side projects for a carpenter" : ""
    @State private var description = ProcessInfo.processInfo.arguments.contains("-brainstorm") ? "Weekends only, under $200 to start" : ""
    @State private var isCreating = false
    @State private var errorMsg: String?
    @State private var isLoading = false
    @State private var hasLoaded = false

    var body: some View {
        HSplitView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Recent topics")
                    .font(.headline)
                    .padding()

                if isLoading {
                    ProgressView().padding()
                } else if ideaBases.isEmpty {
                    Text("No topics yet.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    List(ideaBases) { ib in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(ib.topic)
                                    .font(.subheadline.bold())
                                if let n = ib.postIds?.count, n > 0 {
                                    Text("\(n) ideas")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            if let desc = ib.description {
                                Text(desc)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .frame(minWidth: 200, idealWidth: 240)

            Form {
                Section("Brainstorm a topic") {
                    TextField("Topic", text: $topic)
                        .textFieldStyle(.roundedBorder)
                    TextField("Context (optional)", text: $description)
                        .textFieldStyle(.roundedBorder)

                    if let err = errorMsg {
                        Text(err).foregroundStyle(.red).font(.caption)
                    }

                    HStack {
                        Spacer()
                        Button(action: generate) {
                            if isCreating { ProgressView().controlSize(.small) }
                            else { Text("Write Three Ideas").fontWeight(.semibold) }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .tint(.sparkBlue)
                        .disabled(topic.trimmingCharacters(in: .whitespaces).isEmpty || isCreating || !appState.isLoggedIn)
                        Spacer()
                    }
                }

            }
            .formStyle(.grouped)
        }
        .task {
            guard !hasLoaded else { return }
            await load()
            hasLoaded = true
        }
    }

    private func load() async {
        isLoading = true
        ideaBases = (try? await appState.fetchIdeaBases()) ?? []
        isLoading = false
    }

    private func generate() {
        isCreating = true
        errorMsg = nil
        Task {
            do {
                let ib = try await appState.createIdeaBase(topic: topic, description: description.isEmpty ? nil : description)
                ideaBases.insert(ib, at: 0)
                topic = ""
                description = ""
            } catch {
                errorMsg = error.localizedDescription
            }
            isCreating = false
        }
    }
}
