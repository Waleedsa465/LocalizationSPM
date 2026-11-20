import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public struct BeforeAfterSliderView: View {

    // MARK: - Variables
    let beforeImage: PlatformImage
    let afterImage: PlatformImage
    let beforeTitle: String
    let afterTitle: String
    let cornerRadius: CGFloat
    let badgeColor: Color

    @State private var sliderPosition: CGFloat
    @State private var isDragging = false
    @State private var dragStartPosition: CGFloat

    // MARK: - Init
    public init(
        beforeImage: PlatformImage,
        afterImage: PlatformImage,
        beforeTitle: String = "Before".localized(),
        afterTitle: String = "After".localized(),
        initialPosition: CGFloat = 0.5,
        cornerRadius: CGFloat = 24,
        badgeColor: Color = Color.black.opacity(0.55)
    ) {
        self.beforeImage = beforeImage
        self.afterImage = afterImage
        self.beforeTitle = beforeTitle
        self.afterTitle = afterTitle
        self.cornerRadius = cornerRadius
        self.badgeColor = badgeColor
        let start = min(max(initialPosition, 0), 1)
        _sliderPosition = State(initialValue: start)
        _dragStartPosition = State(initialValue: start)
    }

    // MARK: - Body
    public var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let handleX = width * sliderPosition

            ZStack(alignment: .topLeading) {
                ZStack {
                    platformImage(afterImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width, height: height)
                    labelBadge(afterTitle)
                        .position(x: width - 50, y: height - 32)
                }
                .frame(width: width, height: height)
                .clipped()

                ZStack {
                    platformImage(beforeImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width, height: height)
                    labelBadge(beforeTitle)
                        .position(x: 60, y: height - 32)
                }
                .frame(width: width, height: height)
                .clipped()
                .mask(
                    Rectangle()
                        .frame(width: handleX, height: height)
                        .position(x: handleX / 2, y: height / 2)
                )

                divider(height: height)
                    .position(x: handleX, y: height / 2)
            }
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .contentShape(Rectangle())
            .gesture(dragGesture(width: width))
        }
    }
}

// MARK: - Helpers
extension BeforeAfterSliderView {

    func platformImage(_ image: PlatformImage) -> Image {
        #if os(iOS)
        Image(uiImage: image)
        #else
        Image(nsImage: image)
        #endif
    }

    func dragGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                if !isDragging {
                    isDragging = true
                    dragStartPosition = sliderPosition
                }
                guard width > 0 else { return }
                sliderPosition = min(max(dragStartPosition + value.translation.width / width, 0), 1)
            }
            .onEnded { _ in isDragging = false }
    }

    func labelBadge(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(badgeColor, in: Capsule())
    }

    func divider(height: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .frame(width: 2, height: height)
            Circle()
                .fill(Color.white)
                .frame(width: 36, height: 36)
                .shadow(color: Color.black.opacity(0.25), radius: 4)
                .overlay(
                    HStack(spacing: 3) {
                        Image(systemName: "chevron.left")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.black.opacity(0.7))
                )
                .scaleEffect(isDragging ? 1.1 : 1.0)
                .animation(.easeOut(duration: 0.15), value: isDragging)
        }
    }
}
