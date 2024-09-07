//
//  PullModalTransitioningDelegate.swift
//  OtoFlow
//
//  Created by foyoodo on 2024/9/6.
//

import UIKit

open class PullModalTransitioningDelegate<Base: AnyObject, Target: PullModalViewController>: NSObject, UIViewControllerTransitioningDelegate {

    public let modal: TargetPullModal<Base, Target>

    open var animatedTransition: PullModalAnimatedTransition<Base, Target>

    open var interactiveTransition: PullModalInteractiveTransition<Base, Target>

    public required init(modal: TargetPullModal<Base, Target>) {
        self.modal = modal
        self.animatedTransition = .init(modal: modal)
        self.interactiveTransition = .init(modal: modal)
        self.interactiveTransition.animatedTransition = animatedTransition
    }

    // MARK: UIViewControllerTransitioningDelegate

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        animatedTransition.operation(.present)
    }

    public func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        animatedTransition.operation(.dismiss)
    }

    public func interactionControllerForPresentation(using animator: any UIViewControllerAnimatedTransitioning) -> (any UIViewControllerInteractiveTransitioning)? {
        interactiveTransition
    }

    public func interactionControllerForDismissal(using animator: any UIViewControllerAnimatedTransitioning) -> (any UIViewControllerInteractiveTransitioning)? {
        interactiveTransition
    }

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        nil
    }
}
