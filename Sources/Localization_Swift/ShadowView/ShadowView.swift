import Foundation
import SwiftUI

public struct ShadowView: View {
    
    public var fillColor: Color
    public var shadowColor: Color
    public var cornerRadius: CGFloat = 12
    public var radius: CGFloat = 12
    public var offset: CGSize = .zero
    public var opacity: Double = 0.35
    
    public init(
        fillColor: Color,
        shadowColor: Color,
        cornerRadius: CGFloat = 12,
        radius: CGFloat = 12,
        offset: CGSize = .zero,
        opacity: Double = 0.35
    ) {
        self.fillColor = fillColor
        self.shadowColor = shadowColor
        self.cornerRadius = cornerRadius
        self.radius = radius
        self.offset = offset
        self.opacity = opacity
    }
    
    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(fillColor)
            .shadow(
                color: shadowColor.opacity(opacity),
                radius: radius,
                x: offset.width,
                y: offset.height
            )
    }
}
