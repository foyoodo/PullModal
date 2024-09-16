//
//  UIViewController+PullModal.swift
//  PullModal
//
//  Created by foyoodo on 2024/9/16.
//

import UIKit

private enum AssociatedKeys {
    static var pullModalTransitioningDelegate: UInt8 = 0
}

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
