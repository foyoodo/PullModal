//
//  PullModalTransitionTimingCurve.swift
//  PullModal
//
//  Created by foyoodo on 2024/9/7.
//

import UIKit

open class PullModalTransitionTimingCurve: NSObject, UITimingCurveProvider {

    public var operation: PresentationOperation = .present

    public override init() {
        super.init()
    }

    required public convenience init?(coder: NSCoder) {
        self.init()
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        PullModalTransitionTimingCurve()
    }

    public func encode(with coder: NSCoder) {

    }

    public var timingCurveType: UITimingCurveType {
        .composed
    }

    public var cubicTimingParameters: UICubicTimingParameters? {
        .easeInOutSine()
    }

    public var springTimingParameters: UISpringTimingParameters? {
        .init(dampingRatio: 1.0)
    }
}

extension PullModalTransitionTimingCurve {

    @discardableResult
    public func operation(_ operation: PresentationOperation) -> Self {
        self.operation = operation
        return self
    }
}
