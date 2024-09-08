//
//  PullModalInteractiveTransition.swift
//  PullModal
//
//  Created by foyoodo on 2024/9/6.
//

import UIKit

open class PullModalInteractiveTransition<Base: AnyObject, Target: PullModalViewController>: NSObject, UIViewControllerInteractiveTransitioning, UIGestureRecognizerDelegate {

    public let modal: TargetPullModal<Base, Target>

    public weak var transitionContext: (any UIViewControllerContextTransitioning)?

    public var animatedTransition: PullModalAnimatedTransition<Base, Target>!

    public var operation: PresentationOperation {
        animatedTransition.operation
    }

    public var percentComplete: CGFloat {
        animatedTransition.interruptibleAnimator?.fractionComplete ?? .zero
    }

    open var completionSpeed: CGFloat = 1.0

    open var shouldCompleteTransition: Bool = false

    open var wantsInteractiveStart: Bool = false

    var originalCenter: CGPoint = .zero

    private var containerViewAnchored: Bool = false

    private var contentOffsetObservation: NSKeyValueObservation?

    deinit {
        contentOffsetObservation?.invalidate()
        contentOffsetObservation = nil
    }

    public required init(modal: TargetPullModal<Base, Target>) {
        self.modal = modal

        super.init()

        wire(to: modal.target)
    }

    open func wire(to viewController: UIViewController) {
        prepareGestureRecognzier(for: viewController.view)
    }

    open func prepareGestureRecognzier(for view: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }

    open func pause() {
        transitionContext?.pauseInteractiveTransition()

        animatedTransition?.interruptibleAnimator?.pauseAnimation()
    }

    open func update(_ percentComplete: CGFloat) {
        transitionContext?.updateInteractiveTransition(percentComplete)

        animatedTransition?.interruptibleAnimator?.fractionComplete = percentComplete
    }

    open func cancel(velocity: CGPoint? = nil) {
        transitionContext?.cancelInteractiveTransition()

        let timingParameters: UITimingCurveProvider?
        let durationFactor: CGFloat

        switch operation {
        case .present:
            if let velocity {
                let distance = modal.target.view.bounds.height * percentComplete
                let initialVelocity = max(0, distance > 0 ? velocity.y / distance : 1)
                timingParameters = UISpringTimingParameters(dampingRatio: 1, initialVelocity: .init(dx: 0, dy: initialVelocity))
                completionSpeed = 1.0
            } else {
                timingParameters = UICubicTimingParameters.easeOutQuad()
                completionSpeed = max(1.0, 1.0 / (1 - percentComplete))
                completionSpeed = min(3.0, sqrt(completionSpeed))
            }
            durationFactor = percentComplete
        case .dismiss:
            timingParameters = UICubicTimingParameters.easeInOutSine()
            durationFactor = min(1, percentComplete + 0.2)
        }

        animatedTransition?.interruptibleAnimator?.isReversed = true

        print("cancel percentComplete: \(percentComplete)")

        animatedTransition?.interruptibleAnimator?.continueAnimation(
            withTimingParameters: timingParameters,
            durationFactor: durationFactor / completionSpeed
        )

        // workaround for cubic timing parameters
        if operation == .dismiss {
            animatedTransition?.interruptibleAnimator?.fractionComplete = 1 - percentComplete
        }

        print("cancel percentComplete: \(percentComplete)")
    }

    open func finish(velocity: CGPoint? = nil) {
        transitionContext?.finishInteractiveTransition()

        let timingParameters: UITimingCurveProvider

        switch operation {
        case .present:
            timingParameters = UICubicTimingParameters.easeInOutSine()
            completionSpeed = 1.0
        case .dismiss:
            if let velocity {
                let distance = modal.target.view.bounds.height * (1 - percentComplete)
                let initialVelocity = max(0, distance > 0 ? velocity.y / distance : 1)
                timingParameters = UISpringTimingParameters(dampingRatio: 1, initialVelocity: .init(dx: 0, dy: initialVelocity))
            } else {
                timingParameters = UICubicTimingParameters.easeOutQuad()
            }
            completionSpeed = 1.0
        }

        print("finish: completionSpeed: \(completionSpeed)")

        print("fractionComplete: \(percentComplete)")

        animatedTransition?.interruptibleAnimator?.isReversed = false
        animatedTransition?.interruptibleAnimator?.continueAnimation(
            withTimingParameters: timingParameters,
            durationFactor: (1 - percentComplete) / completionSpeed
        )
    }

    func haltScrolling(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(.zero, animated: false)
    }

    func trackScrolling(_ scrollView: UIScrollView) {
        var contentOffset = scrollView.contentOffset
        contentOffset.y = max(contentOffset.y, -max(scrollView.contentInset.top, 0))
        // ...
    }

    func observeContentOffset(of scrollView: UIScrollView) {
        contentOffsetObservation?.invalidate()
        contentOffsetObservation = scrollView.observe(\.contentOffset) { [unowned self] scrollView, _ in
            let offset = scrollView.contentOffset.y

            if !containerViewAnchored && offset > 0 {
                haltScrolling(scrollView)
            } else if scrollView.isTracking && offset < 0 {
                if containerViewAnchored {
                    trackScrolling(scrollView)
                } else {
                    haltScrolling(scrollView)
                }
            } else {
                trackScrolling(scrollView)
            }
        }
    }

    func shouldFail(panGesture recognizer: UIPanGestureRecognizer) -> Bool {
        guard let scrollView = modal.target.mainScrollView else {
            return true
        }
        return scrollView.contentOffset.y > -max(0, scrollView.adjustedContentInset.top)
    }

    @objc open func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        guard let view = recognizer.view else { return }

        let viewController = modal.target!

        let velocity = recognizer.velocity(in: nil)

        switch recognizer.state {
        case .began:
            recognizer.setTranslation(.zero, in: nil)

            wantsInteractiveStart = true

            if let _ = animatedTransition?.interruptibleAnimator {
                pause()
                containerViewAnchored = false
            } else {
                guard viewController.isBeingDismissed == false else { return }

                viewController.dismiss(animated: true)
            }
        case .changed:
            if shouldFail(panGesture: recognizer) {
                recognizer.setTranslation(.zero, in: nil)
                return
            }

            let translation = recognizer.translation(in: nil)

            let fraction: CGFloat

            switch operation {
            case .present:
                fraction = min(1, max(0, percentComplete - translation.y / view.bounds.height))
                shouldCompleteTransition = fraction - velocity.y / view.bounds.height > 0.6
                containerViewAnchored = fraction == 1
            case .dismiss:
                fraction = min(1, max(0, percentComplete + translation.y / view.bounds.height))
                shouldCompleteTransition = fraction + velocity.y / view.bounds.height > 0.6
                containerViewAnchored = fraction == 0
            }

            update(fraction)

            recognizer.setTranslation(.zero, in: nil)
        case .ended, .cancelled:
            if shouldCompleteTransition {
                finish(velocity: velocity)
            } else {
                cancel(velocity: velocity)
            }
            wantsInteractiveStart = false
        case .failed:
            cancel()
            wantsInteractiveStart = false
        default:
            wantsInteractiveStart = false
        }
    }

    // MARK: UIViewControllerInteractiveTransitioning

    open func startInteractiveTransition(_ transitionContext: any UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext

        animatedTransition.animateTransition(using: transitionContext)

        modal.target.mainScrollView.map(observeContentOffset(of:))
    }

    // MARK: UIGestureRecognizerDelegate

    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        otherGestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer.view === modal.target.mainScrollView
    }

    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        true
    }
}
