import SwiftUI

struct IdeaBaseView: View {
    @Environment(AppState.self) private var appState

    @State private var ideaBases: [IdeaBase] = []
    @State private var rfs: [RFSEntry] = []
    @State private var topic = ""
    @State private var description = ""
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

                if !rfs.isEmpty {
                    Section("Inspiration from YC") {
                        ForEach(rfs) { entry in
                            Link(destination: URL(string: entry.url)!) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.title)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.primary)
                                    Text("By \(entry.author)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    Text(entry.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                            }
                            .buttonStyle(.plain)
                        }
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
        rfs = (try? await appState.fetchRfs()) ?? []
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
