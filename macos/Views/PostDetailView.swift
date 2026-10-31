import SwiftUI

struct PostDetailView: View {
    @Environment(AppState.self) private var appState
    let post: Post

    /// Filled by `loadFull`. The feed list carries no content or enrichment, so
    /// until this arrives the view can only show what the row already had.
    @State private var fullPost: Post?

    private var currentPost: Post {
        // Prefer the fully-loaded copy; the appState entry is a list row and
        // would otherwise mask the body with its own empty fields.
        let listed = appState.posts.first(where: { $0.id == post.id }) ?? post
        guard let full = fullPost, full.id == post.id else { return listed }
        // Votes update the list row, so the live score comes from there.
        var merged = full
        merged.score = listed.score
        return merged
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(currentPost.title)
                    .font(.title2.weight(.bold))
                    .textSelection(.enabled)

                Text(currentPost.content ?? "")
                    .font(.body)
                    .textSelection(.enabled)
                ForEach([("Spec", currentPost.enrichmentSpec), ("Build plan", currentPost.enrichmentPlan)], id: \.0) { heading, text in
                    if let text, !text.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(heading).font(.headline)
                            Text(text).font(.body).textSelection(.enabled)
                        }
                    }
                }

                HStack(spacing: 14) {
                    VoteButton(label: "up", icon: "arrow.up", postId: currentPost.id)
                    Text("\(currentPost.score)")
                        .font(.title3.monospacedDigit().weight(.semibold))
                        .contentTransition(.numericText(value: Double(currentPost.score)))
                        .animation(.spring(duration: 0.3), value: currentPost.score)
                    VoteButton(label: "down", icon: "arrow.down", postId: currentPost.id)
                    Spacer()

                    if canDelete {
                        Button(role: .destructive) {
                            Task {
                                do {
                                    try await appState.deletePost(id: currentPost.id)
                                } catch {
                                    appState.errorBanner = error.localizedDescription
                                }
                            }
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                        .help("Delete post")
                    }

                    ShareLink(item: "\(currentPost.title)\n\n\(currentPost.content ?? "")") {
                        Image(systemName: "square.and.arrow.up")
                    }
                }

                Divider()
                AppStoreMatches(query: currentPost.title)

                Divider()
                CommentsView(postId: currentPost.id)
            }
            .padding(24)
        }
        // Keyed on the id so selecting a different idea reloads rather than
        // leaving the previous post's body on screen.
        .task(id: post.id) {
            fullPost = nil
            fullPost = try? await appState.api.fetchPost(id: post.id)
        }
    }

    private var canDelete: Bool {
        guard let username = appState.user?.username else { return false }
        return currentPost.author?.username == username
    }
}
