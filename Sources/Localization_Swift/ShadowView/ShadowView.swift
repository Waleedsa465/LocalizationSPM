import SwiftUI

public struct ShadowView: View {
    public var shadowColor: Color
    public var cornerRadius: CGFloat
    public var radius: CGFloat
    public var offset: CGSize
    public var opacity: Double
    
    public init(
        shadowColor: Color = .black,
        cornerRadius: CGFloat = 12,
        radius: CGFloat = 12,
        offset: CGSize = .zero,
        opacity: Double = 0.35
    ) {
        self.shadowColor = shadowColor
        self.cornerRadius = cornerRadius
        self.radius = radius
        self.offset = offset
        self.opacity = opacity
    }
    
    public var shadowInset: CGFloat {
        radius + max(abs(offset.width), abs(offset.height))
    }
    
    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }
    
    public var body: some View {
        shape
            .fill(shadowColor.opacity(opacity))
            .shadow(
                color: shadowColor.opacity(opacity),
                radius: radius,
                x: offset.width,
                y: offset.height
            )
            .overlay(shape.blendMode(.destinationOut))
            .compositingGroup()
            .padding(shadowInset)
    }
}
