import Foundation
import CoreGraphics

#if os(iOS)
import UIKit
#else
import Cocoa
#endif

// MARK: - MBProgressHUD

open class MBProgressHUD: PlatformView {
    
    // MARK: Public properties
    open var opacity: CGFloat = 0.8
    open var color: PlatformColor?
    open var margin: CGFloat = 20.0
    open var cornersRadius: CGFloat = 10.0
    
#if os(iOS)
    open var spinSize: CGFloat = 37.0
#else
    open var spinSize: CGFloat = 60.0
#endif
    
    open private(set) var isFinished: Bool = false
    
    // MARK: Private state
    
    private var removeFromSuperViewOnHide: Bool = false
    private var boxSize: CGSize = .zero
    
#if os(iOS)
    private let indicator = UIActivityIndicatorView(style: .large)
#else
    private let indicator = MBSpinner(frame: .zero)
#endif
    
    // MARK: - Class methods
    @discardableResult
    open class func showHUDAdded(to view: PlatformView, animated: Bool) -> MBProgressHUD {
        let hud = MBProgressHUD(view: view)
#if os(iOS)
        view.addSubview(hud)
#else
        view.addSubview(hud, positioned: .above, relativeTo: nil)
#endif
        hud.show(animated: animated)
        return hud
    }
    
    @discardableResult
    open class func hideAllHUDs(for view: PlatformView, animated: Bool) -> Int {
        let huds = view.subviews.compactMap { $0 as? MBProgressHUD }
        for hud in huds {
            hud.removeFromSuperViewOnHide = true
            hud.hide(animated: animated)
        }
        return huds.count
    }
    
    // MARK: - Lifecycle
    
    public convenience init(view: PlatformView) {
        var bounds = view.frame
        bounds.origin = .zero
        self.init(frame: bounds)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
#if os(iOS)
        autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        isOpaque = false
        backgroundColor = .clear
        alpha = 0.0
        indicator.color = .white
        indicator.startAnimating()
#else
        autoresizingMask = [.height, .width, .minXMargin, .maxXMargin, .minYMargin, .maxYMargin]
        wantsLayer = true
        layer?.isOpaque = false
        layer?.backgroundColor = PlatformColor.clear.cgColor
        alphaValue = 0.0
        indicator.color = .white
        indicator.frame = CGRect(x: 0, y: 0, width: spinSize, height: spinSize)
        indicator.startAnimating()
#endif
        addSubview(indicator)
    }
    
    // MARK: - Show & hide
    
    /// Displays the HUD, animating its opacity in if `animated` is true.
    open func show(animated: Bool) {
        setNeedsLayoutAndDisplay()
#if os(iOS)
        if animated {
            UIView.animate(withDuration: 0.30) { self.alpha = 1.0 }
        } else {
            alpha = 1.0
        }
#else
        isHidden = false
        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.30
                self.animator().alphaValue = 1.0
            }
        } else {
            alphaValue = 1.0
        }
#endif
    }
    
    open func hide(animated: Bool) {
#if os(iOS)
        if animated {
            UIView.animate(withDuration: 0.30, animations: {
                self.alpha = 0.0
            }, completion: { _ in self.done() })
        } else {
            alpha = 0.0
            done()
        }
#else
        if animated {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.30
                context.completionHandler = { [weak self] in self?.done() }
                self.animator().alphaValue = 0.0
            })
        } else {
            alphaValue = 0.0
            done()
        }
#endif
    }
    
    private func done() {
        isFinished = true
#if os(iOS)
        alpha = 0.0
#else
        alphaValue = 0.0
        isHidden = true
#endif
        indicator.stopAnimating()
        if removeFromSuperViewOnHide {
            removeFromSuperview()
        }
    }
    
    // MARK: - Layout
    
    private func setNeedsLayoutAndDisplay() {
#if os(iOS)
        setNeedsLayout()
        setNeedsDisplay()
#else
        needsLayout = true
        needsDisplay = true
#endif
    }
    
    private func performLayout() {
        if let parent = superview {
            frame = parent.bounds
        }
        let indicatorSize = indicator.bounds.size
        boxSize = CGSize(width: indicatorSize.width + 2 * margin, height: indicatorSize.height + 2 * margin)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        indicator.frame = CGRect(x: (center.x - indicatorSize.width / 2).rounded(),
                                 y: (center.y - indicatorSize.height / 2).rounded(),
                                 width: indicatorSize.width, height: indicatorSize.height)
    }
    
#if os(iOS)
    open override func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }
    
    open override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        drawBackground(in: context)
    }
#else
    open override func draw(_ dirtyRect: NSRect) {
        performLayout()
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        NSGraphicsContext.saveGraphicsState()
        drawBackground(in: context)
        NSGraphicsContext.restoreGraphicsState()
    }
#endif
    
    private func drawBackground(in context: CGContext) {
        context.setFillColor(color?.cgColor ?? PlatformColor(white: 0.0, alpha: opacity).cgColor)
        
        let boxRect = CGRect(x: ((bounds.width - boxSize.width) / 2).rounded(),
                             y: ((bounds.height - boxSize.height) / 2).rounded(),
                             width: boxSize.width, height: boxSize.height)
        let path = CGPath(roundedRect: boxRect, cornerWidth: cornersRadius, cornerHeight: cornersRadius, transform: nil)
        context.addPath(path)
        context.fillPath()
    }
}

// MARK: - macOS spinner

#if os(macOS)

final class MBSpinner: NSView {
    private let numFins = 12
    private var position = 0
    private var finColors: [NSColor]
    private var timer: Timer?
    
    var color: NSColor = .white
    
    override init(frame frameRect: NSRect) {
        finColors = Array(repeating: .white, count: numFins)
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    required init?(coder: NSCoder) {
        finColors = Array(repeating: .white, count: 12)
        super.init(coder: coder)
    }
    
    isolated deinit { timer?.invalidate() }
    
    func startAnimating() {
        timer?.invalidate()
        position = 0
        let t = Timer(timeInterval: 0.05, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        timer = t
        RunLoop.current.add(t, forMode: .common)
    }
    
    func stopAnimating() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func tick() {
        position = position > 0 ? position - 1 : numFins - 1
        for i in 0..<numFins {
            let fadedAlpha = max(finColors[i].alphaComponent * 0.85, 0.15)
            finColors[i] = color.withAlphaComponent(fadedAlpha)
        }
        finColors[position] = color
        needsDisplay = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let maxSize = min(bounds.width, bounds.height)
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        NSGraphicsContext.saveGraphicsState()
        context.translateBy(x: bounds.width / 2, y: bounds.height / 2)
        
        let path = NSBezierPath()
        path.lineWidth = 0.0859375 * maxSize
        path.lineCapStyle = .round
        path.move(to: NSPoint(x: 0, y: 0.234375 * maxSize))
        path.line(to: NSPoint(x: 0, y: 0.421875 * maxSize))
        
        for i in 0..<numFins {
            finColors[i].set()
            path.stroke()
            context.rotate(by: 6.282185 / CGFloat(numFins))
        }
        
        NSGraphicsContext.restoreGraphicsState()
    }
}

#endif // os(macOS)
