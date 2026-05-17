import SwiftUI

struct ProfileView: View {
    // MARK: - Local state
    @State private var feedbackText: String = ""
    @State private var isSendingFeedback: Bool = false
    @State private var feedbackStatus: FeedbackStatus = .idle
    @State private var feedbackMessage: String = ""

    // MARK: - Stores
    @Environment(UserStore.self) private var userStore

    // MARK: - Computed
    var isPremium: Bool {
        userStore.userCred.type == "premium"
    }

    var canSendFeedback: Bool {
        !feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !isSendingFeedback
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(spacing: 16) {
                    profileCard
                    planCard
                    statsRow
                    feedbackCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
    }

    // MARK: - View builders
    private var header: some View {
        Text("Profile")
            .font(.title.bold())
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            .padding(.bottom, 10)
    }

    private var profileCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Color.gray.opacity(0.4))
                Image(systemName: "person.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white)
            }
            .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(userStore.userCred.name) \(userStore.userCred.surname)")
                    .font(.headline)
                Text(userStore.userCred.email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button {
                    handleLogout()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Log out")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(cardBackground)
    }

    @ViewBuilder
    private var planCard: some View {
        if isPremium {
            premiumPlanCard
        } else {
            trialPlanCard
        }
    }

    private var trialPlanCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "drop.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text("Trial")
                    .font(.headline)
            }

            Divider()

            HStack(alignment: .center, spacing: 12) {
                Text("Get premium, design freely!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
                Button {
                    handleUpgrade()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                        Text("Upgrade")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(cardBackground)
    }

    private var premiumPlanCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Premium")
                        .font(.headline)
                    Text("Monthly")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let renewal = userStore.userCred.nextRenewalDate {
                        Text("Auto renews \(renewal)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Divider()

            HStack(alignment: .center, spacing: 12) {
                Text("Your access continues until the end of your billing period.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
                Button {
                    print("cancel subscription tapped (stub)")
                } label: {
                    Text("Cancel Subscription")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.red.opacity(0.5), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(cardBackground)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(
                symbol: "cylinder.split.1x2.fill",
                value: userStore.userLimits.storageLeft ?? 0,
                label: "Storage left"
            )
            statCard(
                symbol: "wand.and.stars",
                value: userStore.userLimits.designsLeft ?? 0,
                label: "Designs left"
            )
        }
    }

    private func statCard(symbol: String, value: Int, label: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(value)")
                    .font(.headline)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(cardBackground)
    }

    private var feedbackCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "quote.bubble.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text("Feedback")
                    .font(.headline)
            }

            TextField("Anything you want to share?", text: $feedbackText, axis: .vertical)
                .font(.subheadline)
                .lineLimit(3...5)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .disabled(isSendingFeedback)
                .onChange(of: feedbackText) { _, newValue in
                    if newValue.count > 150 {
                        feedbackText = String(newValue.prefix(150))
                    }
                }

            HStack {
                feedbackStatusLabel
                Spacer()
                Text("\(feedbackText.count)/150")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Spacer()
                Button {
                    sendFeedback()
                } label: {
                    Text(isSendingFeedback ? "Sending..." : "Send")
                        .font(.subheadline)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 6)
                        .foregroundStyle(canSendFeedback ? Color.primary : Color.secondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    Color.gray.opacity(canSendFeedback ? 0.6 : 0.3),
                                    lineWidth: 1
                                )
                        )
                }
                .buttonStyle(.plain)
                .disabled(!canSendFeedback)
            }
        }
        .padding(14)
        .background(cardBackground)
    }

    @ViewBuilder
    private var feedbackStatusLabel: some View {
        switch feedbackStatus {
        case .success:
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle")
                Text(feedbackMessage)
            }
            .font(.caption)
            .foregroundStyle(.green)
        case .error:
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.circle")
                Text(feedbackMessage)
            }
            .font(.caption)
            .foregroundStyle(.red)
        case .idle, .sending:
            EmptyView()
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
    }

    // MARK: - Action methods
    private func handleLogout() {
        print("logout tapped (stub)")
    }

    private func handleUpgrade() {
        print("upgrade tapped (stub)")
    }

    private func sendFeedback() {
        guard canSendFeedback else { return }
        isSendingFeedback = true
        feedbackStatus = .sending
        feedbackMessage = ""

        Task {
            try? await Task.sleep(for: .seconds(1))
            await MainActor.run {
                feedbackStatus = .success
                feedbackMessage = "Thank you for your feedback!"
                feedbackText = ""
                isSendingFeedback = false
            }
            try? await Task.sleep(for: .seconds(3))
            await MainActor.run {
                if feedbackStatus == .success {
                    feedbackStatus = .idle
                    feedbackMessage = ""
                }
            }
        }
    }
}

// MARK: - Local types
enum FeedbackStatus {
    case idle, sending, success, error
}

// MARK: - Preview
#Preview {
    ProfileView()
        .environment(UserStore.preview)
}
