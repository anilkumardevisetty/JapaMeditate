import SwiftUI

/// A reusable rounded “panel” that groups multiple tiles into one container.
/// ✅ ScrollView-safe (no GeometryReader / no vertical centering)
struct AppPanel<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass

    private let cornerRadius: CGFloat
    private let fill: Color
    private let strokeOpacity: Double
    private let shadowOpacity: Double
    private let contentPadding: CGFloat
    private let maxWidthRegular: CGFloat?
    private let content: Content

    init(
        cornerRadius: CGFloat = 32,
        fill: Color = .white,
        strokeOpacity: Double = 0.06,
        shadowOpacity: Double = 0.12,
        contentPadding: CGFloat = 14,
        maxWidthRegular: CGFloat? = 640,   // iPad max width (nil = no cap)
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.fill = fill
        self.strokeOpacity = strokeOpacity
        self.shadowOpacity = shadowOpacity
        self.contentPadding = contentPadding
        self.maxWidthRegular = maxWidthRegular
        self.content = content()
    }

    var body: some View {
        content
            .padding(contentPadding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fill)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.black.opacity(strokeOpacity), lineWidth: 1)
            )
            .shadow(color: .black.opacity(shadowOpacity), radius: 18, y: 10)

            // ✅ Center horizontally + optional width cap on iPad
            .frame(maxWidth: panelMaxWidth)
            .frame(maxWidth: .infinity, alignment: .center)

            // ✅ consistent outer spacing
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
    }

    private var panelMaxWidth: CGFloat? {
        if hSizeClass == .regular {
            return maxWidthRegular
        }
        return nil // iPhone: use available width
    }
}
