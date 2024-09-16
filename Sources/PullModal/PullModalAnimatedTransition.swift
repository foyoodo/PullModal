//
//  PullModalAnimatedTransition.swift
//  PullModal
//
//  Created by foyoodo on 2024/9/6.
//

import UIKit

open class PullModalAnimatedTransition<Base: AnyObject, Target: PullModalViewController>: NSObject, UIViewControllerAnimatedTransitioning {

    public let modal: TargetPullModal<Base, Target>

    public var operation: PresentationOperation = .present

    public private(set) var interruptibleAnimator: UIViewPropertyAnimator?

    open var destinationContainer: UIView {
        modal.target.view
    }

    public init(modal: TargetPullModal<Base, Target>) {
        self.modal = modal
    }

    open func prepareTransition(
        for animator: UIViewPropertyAnimator,
        transitionContext: any UIViewControllerContextTransitioning,
        containerView: UIView,
        fromViewController: UIViewController,
        toViewController: UIViewController,
        fromView: UIView,
        toView: UIView
    ) {
        switch operation {
        case .present:
            let toViewEndFrame = transitionContext.finalFrame(for: toViewController)
            let toViewStartFrame = CGRect(
                origin: .init(x: .zero, y: containerView.bounds.height),
                size: toViewEndFrame.size
            )

            toView.frame = toViewStartFrame
            containerView.addSubview(toView)

            animator.addAnimations {
                toView.frame = toViewEndFrame
            }

            animator.addCompletion { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        case .dismiss:
            let fromViewEndFrame = CGRect(
                origin: .init(x: .zero, y: containerView.bounds.height),
                size: containerView.bounds.size
            )

            animator.addAnimations {
                fromView.frame = fromViewEndFrame
            }

            animator.addCompletion { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }

        adjustCornerRadius(
            animator: animator,
            containerView: containerView,
            fromView: fromView,
            toView: toView
        )
    }

    open func adjustCornerRadius(
        animator: UIViewPropertyAnimator,
        containerView: UIView,
        fromView: UIView,
        toView: UIView
    ) {
        guard case .fullScreen = modal.detent else { return }

        switch operation {
        case .present:
            toView.layer.maskedCorners = .minY

            animator.addAnimations {
                toView.setCornerRadius(containerView.window?.screen.displayCornerRadius ?? 0).adjustMasksToBounds()
            }
            animator.addCompletion { _ in
                toView.setCornerRadius(0).adjustMasksToBounds()
            }
        case .dismiss:
            fromView.layer.maskedCorners = .minY
            fromView.setCornerRadius(containerView.window?.screen.displayCornerRadius ?? 0).adjustMasksToBounds()

            animator.addAnimations {
                fromView.setCornerRadius(0)
            }
            animator.addCompletion { _ in
                fromView.layer.maskedCorners = .all
                fromView.setCornerRadius(0).adjustMasksToBounds()
            }
        }
    }

    // MARK: UIViewControllerAnimatedTransitioning

    open func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        modal.duration
    }

    open func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        let animator = interruptibleAnimator(using: transitionContext)
        if !transitionContext.isInteractive {
            animator.startAnimation()
        } else {
            animator.pauseAnimation()
        }
    }

    open func interruptibleAnimator(using transitionContext: any UIViewControllerContextTransitioning) -> any UIViewImplicitlyAnimating {
        if let interruptibleAnimator {
            return interruptibleAnimator
        }

        let animator = UIViewPropertyAnimator(
            duration: transitionDuration(using: transitionContext),
            timingParameters: PullModalTransitionTimingCurve().operation(operation)
        )

        interruptibleAnimator = animator

        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to)
        else {
            return animator
        }

        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)

        prepareTransition(
            for: animator,
            transitionContext: transitionContext,
            containerView: containerView,
            fromViewController: fromVC,
            toViewController: toVC,
            fromView: fromView ?? fromVC.view,
            toView: toView ?? toVC.view
        )

        return animator
    }

    open func animationEnded(_ transitionCompleted: Bool) {
        interruptibleAnimator = nil
    }
}

extension PullModalAnimatedTransition {

    @discardableResult
    public func operation(_ operation: PresentationOperation) -> Self {
        self.operation = operation
        return self
    }
}
