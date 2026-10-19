import SwiftUI

struct CommentsView: View {
    @Environment(AppState.self) private var appState
    let postId: String

    @State private var newComment = ""
    @State private var isPosting = false

    private var postComments: [Comment] {
        appState.comments[postId] ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Comments")
                    .font(.headline)
                Spacer()
                Text("\(postComments.count)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            if appState.isLoggedIn {
                HStack(spacing: 8) {
                    TextField("Add a comment...", text: $newComment, axis: .vertical)
                        .lineLimit(1...4)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(postComment)
                    Button(action: postComment) {
                        if isPosting {
                            ProgressView().controlSize(.small)
                        } else {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title3)
                                .foregroundStyle(canPost ? Color.sparkBlue : Color.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(!canPost)
                }
            }

            if postComments.isEmpty {
                Text("No comments yet. Be the first.")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            } else {
                ForEach(postComments) { comment in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(comment.username)
                            .font(.caption.bold())
                        Text(comment.content)
                            .font(.subheadline)
                            .textSelection(.enabled)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .task(id: postId) {
            await appState.loadComments(postId: postId)
        }
    }

    private var canPost: Bool {
        let trimmed = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= 2000 && !isPosting
    }

    private func postComment() {
        guard canPost else { return }
        isPosting = true
        Task {
            do {
                try await appState.addComment(postId: postId, content: newComment)
                newComment = ""
            } catch {
                appState.errorBanner = error.localizedDescription
            }
            isPosting = false
        }
    }
}
