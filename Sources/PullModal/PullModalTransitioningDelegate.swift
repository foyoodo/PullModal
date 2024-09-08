//
//  PullModalTransitioningDelegate.swift
//  PullModal
//
//  Created by foyoodo on 2024/9/6.
//

import UIKit

open class PullModalTransitioningDelegate<Base: AnyObject, Target: PullModalViewController>: NSObject, UIViewControllerTransitioningDelegate {

    public var modal: TargetPullModal<Base, Target>

    open var animatedTransition: PullModalAnimatedTransition<Base, Target>?

    open var interactiveTransition: PullModalInteractiveTransition<Base, Target>?

    public required init(modal: TargetPullModal<Base, Target>) {
        self.modal = modal

        super.init()

        prepareTransition()
    }

    open func prepareTransition() {
        animatedTransition = .init(modal: modal)
        interactiveTransition = .init(modal: modal)
        interactiveTransition!.animatedTransition = animatedTransition
    }

    // MARK: UIViewControllerTransitioningDelegate

    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        animatedTransition?.operation(.present)
    }

    open func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        animatedTransition?.operation(.dismiss)
    }

    open func interactionControllerForPresentation(using animator: any UIViewControllerAnimatedTransitioning) -> (any UIViewControllerInteractiveTransitioning)? {
        interactiveTransition
    }

    open func interactionControllerForDismissal(using animator: any UIViewControllerAnimatedTransitioning) -> (any UIViewControllerInteractiveTransitioning)? {
        interactiveTransition
    }

    open func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PullModalPresentationController(presentedViewController: presented, presenting: presenting, modal: modal)
    }
}
