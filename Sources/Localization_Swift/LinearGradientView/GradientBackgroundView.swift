import Foundation
import SwiftUI

public struct GradientBackgroundView: View {
    
    var colors: [Color]
    var startPoint: UnitPoint = .leading
    var endPoint: UnitPoint = .trailing
    var cornerRadius: CGFloat = 12
    
    var shimmer: Bool = true
    var breathing: Bool = true
    
    @State private var shimmerPulse: CGFloat = 0
    @State private var isBreathing = false
    
    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }
    
    public var body: some View {
        GeometryReader { geo in
            let maxRadius = max(geo.size.width, geo.size.height, 1)
            let radius = 8 + shimmerPulse * maxRadius
            
            LinearGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
                .overlay {
                    if shimmer {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        .white.opacity(0.35),
                                        .white.opacity(0.0),
                                        .white.opacity(0.18),
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: radius
                                )
                            )
                            .frame(width: radius * 2, height: radius * 2)
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                            .opacity(1.0 - Double(shimmerPulse))
                            .blendMode(.overlay)
                            .allowsHitTesting(false)
                    }
                }
                .clipShape(shape)
                .brightness(isBreathing ? 0.06 : -0.02)
                .scaleEffect(isBreathing ? 1.0 : 0.94)
        }
        .animation(
            breathing
            ? .easeInOut(duration: 1.08).repeatForever(autoreverses: true)
            : nil,
            value: isBreathing
        )
        .onAppear {
            if breathing { isBreathing = true }
            if shimmer {
                shimmerPulse = 0
                withAnimation(.easeOut(duration: 2.4).repeatForever(autoreverses: false)) {
                    shimmerPulse = 1
                }
            }
        }
    }
}
