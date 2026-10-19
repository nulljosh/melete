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
                HStack(spacing: 10) {
                    CategoryBadge(category: currentPost.category)
                    Spacer()
                    if let createdAt = currentPost.createdAt {
                        Text(relativeDate(createdAt))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(currentPost.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    Image(systemName: "person.crop.circle")
                        .foregroundStyle(.secondary)
                    Text(currentPost.author?.username ?? "Unknown")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if currentPost.enriched == true {
                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundStyle(Color.bulbDeep)
                    } else if currentPost.enrichmentRequestedAt != nil {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }

                if let repo = currentPost.linkedRepo, let url = URL(string: repo) {
                    Link(destination: url) {
                        Label(repo, systemImage: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundStyle(.blue)
                            .lineLimit(1)
                    }
                }

                Divider()

                Text(detail.content ?? "")
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                // LLM enrichment panels
                if let spec = detail.enrichmentSpec, !spec.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SPEC")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(spec)
                            .font(.callout)
                            .foregroundStyle(.primary)
                    }
                }

                if let plan = detail.enrichmentPlan, !plan.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PLAN")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(plan)
                            .font(.callout)
                            .foregroundStyle(.primary)
                    }
                }

                if detail.enriched == true {
                    Divider()
                    AppStoreMatches(query: detail.title)
                }

                Divider()

                HStack(spacing: 14) {
                    VoteButton(label: "up", icon: "arrow.up", postId: currentPost.id)
                    Text("\(currentPost.score)")
                        .font(.title3.monospacedDigit().weight(.semibold))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText(value: Double(currentPost.score)))
                        .animation(.spring(duration: 0.3), value: currentPost.score)
                    VoteButton(label: "down", icon: "arrow.down", postId: currentPost.id)
                    Spacer()
                    ScoreBadge(score: currentPost.score)
                }

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
            ToolbarItemGroup(placement: .topBarTrailing) {
                if appState.isLoggedIn && !(currentPost.enriched ?? false) && currentPost.enrichmentRequestedAt == nil {
                    Button {
                        Task { try? await appState.requestEnrichment(postId: currentPost.id) }
                    } label: {
                        Image(systemName: "wand.and.stars")
                    }
                }
                ShareLink(item: "\(currentPost.title)\n\n\(detail.content ?? "")") {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }

    private func relativeDate(_ iso: String) -> String {
        DateFormatting.relativeDate(iso)
    }
}
