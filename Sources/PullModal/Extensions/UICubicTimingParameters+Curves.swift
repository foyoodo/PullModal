import UIKit

/// https://easings.net
extension UICubicTimingParameters {

    public static func easeInSine() -> UICubicTimingParameters { .init(0.47, 0, 0.745, 0.715) }
    public static func easeOutSine() -> UICubicTimingParameters { .init(0.39, 0.575, 0.565, 1) }
    public static func easeInOutSine() -> UICubicTimingParameters { .init(0.445, 0.05, 0.55, 0.95) }
    public static func easeInQuad() -> UICubicTimingParameters { .init(0.55, 0.085, 0.68, 0.53) }
    public static func easeOutQuad() -> UICubicTimingParameters { .init(0.25, 0.46, 0.45, 0.94) }
    public static func easeInOutQuad() -> UICubicTimingParameters { .init(0.455, 0.03, 0.515, 0.955) }
    public static func easeInCubic() -> UICubicTimingParameters { .init(0.55, 0.055, 0.675, 0.19) }
    public static func easeOutCubic() -> UICubicTimingParameters { .init(0.215, 0.61, 0.355, 1) }
    public static func easeInOutCubic() -> UICubicTimingParameters { .init(0.645, 0.045, 0.355, 1) }
    public static func easeInQuart() -> UICubicTimingParameters { .init(0.895, 0.03, 0.685, 0.22) }
    public static func easeOutQuart() -> UICubicTimingParameters { .init(0.165, 0.84, 0.44, 1) }
    public static func easeInOutQuart() -> UICubicTimingParameters { .init(0.77, 0, 0.175, 1) }
    public static func easeInQuint() -> UICubicTimingParameters { .init(0.755, 0.05, 0.855, 0.06) }
    public static func easeOutQuint() -> UICubicTimingParameters { .init(0.23, 1, 0.32, 1) }
    public static func easeInOutQuint() -> UICubicTimingParameters { .init(0.86, 0, 0.07, 1) }
    public static func easeInExpo() -> UICubicTimingParameters { .init(0.95, 0.05, 0.795, 0.035) }
    public static func easeOutExpo() -> UICubicTimingParameters { .init(0.19, 1, 0.22, 1) }
    public static func easeInOutExpo() -> UICubicTimingParameters { .init(1, 0, 0, 1) }
    public static func easeInCirc() -> UICubicTimingParameters { .init(0.6, 0.04, 0.98, 0.335) }
    public static func easeOutCirc() -> UICubicTimingParameters { .init(0.075, 0.82, 0.165, 1) }
    public static func easeInOutCirc() -> UICubicTimingParameters { .init(0.785, 0.135, 0.15, 0.86) }
    public static func easeInBack() -> UICubicTimingParameters { .init(0.6, -0.28, 0.735, 0.045) }
    public static func easeOutBack() -> UICubicTimingParameters { .init(0.175, 0.885, 0.32, 1.275) }
    public static func easeInOutBack() -> UICubicTimingParameters { .init(0.68, -0.55, 0.265, 1.55) }

    fileprivate convenience init(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat) {
        self.init(controlPoint1: .init(x: x1, y: y1), controlPoint2: .init(x: x2, y: y2))
    }
}
