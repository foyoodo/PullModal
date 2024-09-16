//
//  PullModal.swift
//  PullModal
//
//  Created by foyoodo on 2024/9/6.
//

import UIKit

public class PullModal<Base: AnyObject>: Modal {

    public var duration: TimeInterval = 0.5

    public var detent: ModalDetent = .fullScreen

    public var cornerRadius: CGFloat = 22.0

    public var dimmedAlpha: CGFloat = 0.4

    public private(set) weak var base: Base?

    public init(_ base: Base) {
        self.base = base
    }

    public func config(_ closure: (_ model: Modal) -> Void) -> Self {
        closure(self)
        return self
    }
}

extension PullModal {

    public func duration(_ duration: TimeInterval) -> Self {
        self.duration = duration
        return self
    }

    public func detent(_ detent: ModalDetent) -> Self {
        self.detent = detent
        return self
    }

    public func cornerRadius(_ cornerRadius: CGFloat) -> Self {
        self.cornerRadius = cornerRadius
        return self
    }

    public func dimmedAlpha(_ alpha: CGFloat) -> Self {
        self.dimmedAlpha = alpha
        return self
    }

    @discardableResult
    public func removeDimmed() -> Self {
        self.dimmedAlpha = 0.0
        return self
    }
}
