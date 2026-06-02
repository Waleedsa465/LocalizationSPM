#if os(macOS)
internal import SwiftUI

struct ToastView: View {
    let message: String
    let textColor: Color
    let viewBackGroundColor: Color
    let icon: Image?
    weak var panel: NSPanel?
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.primary)
            }
            if #available(macOS 12.0, *) {
                Text(message)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(textColor)
            } else {
                Text(message)
                    .multilineTextAlignment(.leading)
                textColor
            }
        }
        .onTapGesture {
            guard let panel = panel else { return }
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                panel.animator().alphaValue = 0
            }, completionHandler: {
                Task{ @MainActor in panel.orderOut(nil) }
            })
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(viewBackGroundColor)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.primary.opacity(0.1), lineWidth: 0.1)
        )
        .frame(maxWidth: 300)
    }
}
#endif
