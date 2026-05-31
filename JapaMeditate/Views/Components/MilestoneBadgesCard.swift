import SwiftUI

struct MilestoneBadgesCard: View {
    let title: String
    let milestones: [PracticeMilestone]
    let theme: AppTheme

    private let columns: [GridItem] = Array(
        repeating: GridItem(.flexible(), spacing: 10),
        count: 2
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("\(unlockedCount) of \(milestones.count) unlocked")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                Image(systemName: "rosette")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
            }

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(milestones) { milestone in
                    MilestoneBadgeTile(milestone: milestone)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.background)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
    }
}

private extension MilestoneBadgesCard {
    var unlockedCount: Int {
        milestones.filter(\.isUnlocked).count
    }
}

struct PracticeMilestone: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    let isUnlocked: Bool
}

private struct MilestoneBadgeTile: View {
    let milestone: PracticeMilestone

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: milestone.systemImage)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(iconColor)

                Spacer()

                Image(systemName: milestone.isUnlocked ? "checkmark.circle.fill" : "lock.fill")
                    .font(.caption)
                    .foregroundColor(statusColor)
            }

            Text(milestone.title)
                .font(.caption.bold())
                .foregroundColor(.white)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(milestone.subtitle)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.82))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
        .background(tileBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(milestone.isUnlocked ? 0.28 : 0.10), lineWidth: 1)
        )
        .cornerRadius(16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
}

private extension MilestoneBadgeTile {
    var tileBackground: Color {
        milestone.isUnlocked ? Color.white.opacity(0.20) : Color.white.opacity(0.10)
    }

    var iconColor: Color {
        milestone.isUnlocked ? .white : .white.opacity(0.55)
    }

    var statusColor: Color {
        milestone.isUnlocked ? .white : .white.opacity(0.55)
    }

    var accessibilityLabel: String {
        "\(milestone.title), \(milestone.subtitle), \(milestone.isUnlocked ? "unlocked" : "locked")"
    }
}
