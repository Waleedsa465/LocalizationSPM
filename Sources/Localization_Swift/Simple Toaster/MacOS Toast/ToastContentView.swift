#if os(macOS)
import SwiftUI

struct ToastView: View {
    let message: String
    let textColor: Color
    let viewBackGroundColor: Color
    let icon: Image?
    weak var panel: NSPanel?
    let textWidth: CGFloat

    @ViewBuilder
    private var messageText: some View {
        if #available(macOS 12.0, *) {
            Text(message)
                .multilineTextAlignment(.leading)
                .foregroundStyle(textColor)
                .frame(width: textWidth, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            Text(message)
                .multilineTextAlignment(.leading)
                .foregroundColor(textColor)
                .frame(width: textWidth, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.primary)
            }
            messageText
        }
        .onTapGesture {
            guard let panel = panel else { return }
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                panel.animator().alphaValue = 0
            }, completionHandler: {
                Task { @MainActor in panel.orderOut(nil) }
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
    }
}
#endif
