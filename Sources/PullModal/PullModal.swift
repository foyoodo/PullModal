//
//  PullModal.swift
//  PullModal
//
//  Created by foyoodo on 2024/9/6.
//

import UIKit

private enum AssociatedKeys {
    static var pullModalTransitioningDelegate: UInt8 = 0
    static var pullModalPresentationController: UInt8 = 0
}

public struct PullModal<Base: AnyObject> {

    var duration: TimeInterval = 0.6

    public private(set) weak var base: Base?

    public init(_ base: Base) {
        self.base = base
    }
}

public struct TargetPullModal<Base: AnyObject, Target: PullModalViewController> {

    let modal: PullModal<Base>

    public weak var target: Target!

    public var base: Base? {
        modal.base
    }

    init(_ modal: PullModal<Base>, target: Target) {
        self.modal = modal
        self.target = target
    }
}

extension TargetPullModal {

    var duration: TimeInterval {
        modal.duration
    }
}

public protocol PullModalCompatible: AnyObject { }

extension PullModalCompatible {

    public var pullModal: PullModal<Self> {
        get { PullModal(self) }
        set { }
    }
}

extension UIViewController: PullModalCompatible { }

extension PullModal where Base: UIViewController {

    public func present<Target>(
        _ viewControllerToPresent: Target,
        animated: Bool = true
    ) where Target: PullModalViewController {
        self.present(
            viewControllerToPresent,
            using: PullModalTransitioningDelegate<Base, Target>.self,
            animated: animated
        )
    }

    public func present<Target>(
        _ viewControllerToPresent: Target,
        using transitioningDelegate: PullModalTransitioningDelegate<Base, Target>.Type,
        animated: Bool = true
    ) where Target: PullModalViewController {
        guard let viewController = base else { return }

        let modal = TargetPullModal(self, target: viewControllerToPresent)

        let transitioningDelegate = transitioningDelegate.init(modal: modal)

        objc_setAssociatedObject(viewControllerToPresent, &AssociatedKeys.pullModalTransitioningDelegate, transitioningDelegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        viewControllerToPresent.modalPresentationStyle = .custom
        viewControllerToPresent.transitioningDelegate = transitioningDelegate

        viewController.present(viewControllerToPresent, animated: animated)
    }
}
