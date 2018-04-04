import UIKit

public class GliderView: UIView {
    public var resource: GliderResource? {
        didSet {
            resourceLayer?.removeFromSuperlayer()
            resourceLayer = nil
            drawResource()
        }
    }

    public var completion: (() -> ())?
    public var repeatCount: Int = 1
    public var loops: Bool {
        get {
            return repeatCount == Int.max
        }
        set {
            repeatCount = newValue ? Int.max : 0
        }
    }

    public var autoreverses: Bool = false //TODO
    fileprivate var isAnimating: Bool = false
    private var resourceLayer: CALayer?

    fileprivate var repeatCurrentCount: Int = 0
    private var startAnimatingWhenResourceLoads = false

    convenience public init(resource: GliderResource) {
        self.init()

        self.resource = resource
        drawResource()
    }

    init() {
        super.init(frame: .zero)

        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    func commonInit() {
        clipsToBounds = true
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        layoutResourceLayer()
    }

    public override var intrinsicContentSize: CGSize {
        guard let rLayer = resourceLayer else {
            return .zero
        }

        return rLayer.bounds.size
    }

    private func drawResource() {
        guard let resource = resource else {
            return
        }

        resource.load { result in
            switch result {
            case .success(let layer):
                self.resourceLayer = layer
                self.invalidateIntrinsicContentSize()
                self.layoutResourceLayer()
            default:
                break
            }
        }
    }

    private func layoutResourceLayer() {
        guard let rLayer = resourceLayer else {
            return
        }

        rLayer.flipGeometry()
        rLayer.isGeometryFlipped = true
        rLayer.masksToBounds = true
        layer.addSublayer(rLayer)

        let layerWidth = rLayer.bounds.width
        let layerHeight = rLayer.bounds.height

        let aspectWidth  = bounds.width / layerWidth
        let aspectHeight = bounds.height / layerHeight

        switch contentMode {
        case .center:
            rLayer.transform = CATransform3DMakeTranslation((bounds.width - layerWidth)/2.0,
                                                            (bounds.height - layerHeight)/2.0,
                                                            0)
        case .scaleToFill:
            rLayer.transform = CATransform3DMakeScale(bounds.width/layerWidth,
                                                      bounds.height/layerHeight,
                                                      1)
        case .scaleAspectFill:
            let fillRatio = max(aspectWidth, aspectHeight)
            rLayer.transform = transform(for: fillRatio, contentSize: rLayer.bounds.size)
        default:
            if contentMode != .scaleAspectFit {
                //TODO: Support other content modes
                print("Unsupported content mode; setting to scaleAspectFit")
            }

            let fitRatio = min(aspectWidth, aspectHeight)
            rLayer.transform = transform(for: fitRatio, contentSize: rLayer.bounds.size)
        }

        if startAnimatingWhenResourceLoads {
            startAnimatingWhenResourceLoads = false
            startAnimating()
        }
    }

    private func transform(for ratio: CGFloat, contentSize: CGSize) -> CATransform3D {
        let scale = CATransform3DMakeScale(ratio,
                                           ratio,
                                           1)
        let translation = CATransform3DMakeTranslation((bounds.width - (contentSize.width * ratio))/2.0,
                                                       (bounds.height - (contentSize.height * ratio))/2.0,
                                                       0)
        return CATransform3DConcat(scale, translation)
    }

    public func startAnimating() {
        guard let rLayer = resourceLayer else {
            startAnimatingWhenResourceLoads = true
            return
        }

        guard !isAnimating else {
            return
        }

        if let last = rLayer.lastAnimationToFinish() {
            let animationCopy = last.animation.mutableCopy() as! CAAnimation
            last.layer.removeAnimation(forKey: last.animationKey)
            animationCopy.delegate = self
            last.layer.add(animationCopy, forKey: last.animationKey)
        }

        rLayer.speed = 1
        rLayer.beginTime = CACurrentMediaTime()
    }

    public func rewind(andPlay: Bool) {
        resourceLayer?.speed = 0
        resourceLayer?.timeOffset = 0

        if andPlay {
            startAnimating()
        }
    }

    public func pause() {
        isAnimating = false
        resourceLayer?.speed = 0.0
        resourceLayer?.timeOffset = resourceLayer!.convertTime(CACurrentMediaTime(), from: nil)
    }

    public func stopAnimating() {
        isAnimating = false
        repeatCurrentCount = 0
        startAnimatingWhenResourceLoads = false
        rewind(andPlay: false)
    }
}

extension GliderView: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        isAnimating = false
        repeatCurrentCount += 1

        if flag {
            if repeatCount == repeatCurrentCount {
                completion?()
                completion = nil
            } else if repeatCount > repeatCurrentCount {
                rewind(andPlay: true)
            }
        }
    }
}

private extension CALayer {
    func flipGeometry() {
        isGeometryFlipped = true
        sublayers?.forEach { $0.flipGeometry() }
    }

    func lastAnimationToFinish() -> (animation: CAAnimation, layer: CALayer, animationKey: String)? {
        var lastAnimation: CAAnimation? = nil
        var lastFinishTime: CFTimeInterval = 0
        var layer: CALayer? = nil
        var animationKey: String? = nil

        animationKeys()?.forEach {
            let aAnimation = animation(forKey: $0)!
            if beginTime + aAnimation.finishTime > lastFinishTime {
                lastAnimation = aAnimation
                lastFinishTime = beginTime + aAnimation.finishTime
                layer = self
                animationKey = $0
            }
        }

        sublayers?.forEach { sLayer in
            if let last = sLayer.lastAnimationToFinish(),
                beginTime + last.animation.finishTime > lastFinishTime {
                lastAnimation = last.animation
                lastFinishTime = beginTime + last.animation.finishTime
                layer = last.layer
                animationKey = last.animationKey
            }
        }

        if
            let animation = lastAnimation,
            let layer = layer,
            let animationKey = animationKey {
            return (animation, layer, animationKey)
        }

        return nil
    }
}

private extension CAAnimation {
    var finishTime: CFTimeInterval {
        return beginTime + duration
    }
}

