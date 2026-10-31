import SwiftUI

struct PostDetailView: View {
    @Environment(AppState.self) private var appState
    let post: Post
    @State private var fullPost: Post?

    private var currentPost: Post {
        appState.posts.first(where: { $0.id == post.id }) ?? post
    }

    // The feed list omits content and the enrichment columns, so the body, spec
    // and plan come from the fully-loaded copy. Score stays live from appState.
    private var detail: Post { fullPost ?? currentPost }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(currentPost.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(detail.content ?? "")
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                ForEach([("Spec", detail.enrichmentSpec), ("Build plan", detail.enrichmentPlan)], id: \.0) { heading, text in
                    if let text, !text.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(heading).font(.headline)
                            Text(text).font(.body).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                HStack(spacing: 14) {
                    VoteButton(label: "up", icon: "arrow.up", postId: currentPost.id)
                    Text("\(currentPost.score)")
                        .font(.title3.monospacedDigit().weight(.semibold))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText(value: Double(currentPost.score)))
                        .animation(.spring(duration: 0.3), value: currentPost.score)
                    VoteButton(label: "down", icon: "arrow.down", postId: currentPost.id)
                }

                Divider()
                AppStoreMatches(query: currentPost.title)

                Divider()
                CommentsView(postId: currentPost.id)
            }
            .padding(16)
        }
        .background(Color.paper)
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: post.id) {
            fullPost = try? await appState.api.fetchPost(id: post.id)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: "\(currentPost.title)\n\n\(detail.content ?? "")") {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
}
