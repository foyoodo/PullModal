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

    public var isTransitioning = false

    public var percentComplete: CGFloat {
        animatedTransition.interruptibleAnimator?.fractionComplete ?? .zero
    }

    open var completionSpeed: CGFloat = 1.0

    open var shouldCompleteTransition: Bool = false

    open var wantsInteractiveStart: Bool = false

    open var containerViewAnchored: Bool = false

    open var destinationOriginalCenter: CGPoint = .zero

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

        animatedTransition?.interruptibleAnimator?.continueAnimation(
            withTimingParameters: timingParameters,
            durationFactor: durationFactor / completionSpeed
        )

        // workaround for cubic timing parameters
        if operation == .dismiss {
            animatedTransition?.interruptibleAnimator?.fractionComplete = 1 - percentComplete
        }
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
        // disable dismiss interruption
        guard operation == .present else {
            return true
        }

        guard let scrollView = modal.target.mainScrollView else {
            return true
        }

        return scrollView.contentOffset.y > -max(0, scrollView.adjustedContentInset.top)
    }

    open func handlePanGestureBegan(_ recognizer: UIPanGestureRecognizer) {
        // interrupt the presentation
        wantsInteractiveStart = true

        if isTransitioning {
            pause()
            containerViewAnchored = false
        } else {
            destinationOriginalCenter = modal.target.view.center
        }
    }

    @objc open func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        if shouldFail(panGesture: recognizer) {
            recognizer.setTranslation(.zero, in: nil)
            return
        }

        if recognizer.state == .began {
            handlePanGestureBegan(recognizer)
            return
        }

        let velocity = recognizer.velocity(in: nil)

        switch recognizer.state {
        case .changed:
            let translation = recognizer.translation(in: nil)

            if isTransitioning {
                guard let view = recognizer.view else { return }

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

                if fraction == 1.0 {
                    finish()
                    isTransitioning = false
                    destinationOriginalCenter = modal.target.view.center
                }
            } else {
                guard let destinationView = animatedTransition?.destinationContainer else {
                    break
                }

                if translation.y > 0 {
                    destinationView.center.y += translation.y
                } else {
                    if destinationView.center.y + translation.y > destinationOriginalCenter.y {
                        destinationView.center.y += translation.y
                    } else {
                        destinationView.center = destinationOriginalCenter
                    }
                }

                containerViewAnchored = destinationView.center == destinationOriginalCenter
            }

            recognizer.setTranslation(.zero, in: nil)
        case .ended, .cancelled:
            if isTransitioning {
                if shouldCompleteTransition {
                    finish(velocity: velocity)
                } else {
                    cancel(velocity: velocity)
                }
            } else {
                if !restoreDestinationPosition(velocity: velocity) {
                    modal.target.dismiss(animated: true)
                    isTransitioning = true
                }
            }
        case .failed:
            if isTransitioning {
                cancel()
            } else {
                restoreDestinationPosition()
            }
        default: ()
        }

        wantsInteractiveStart = false
    }

    open func restoreDestinationPosition(velocity: CGPoint) -> Bool {
        guard let destinationView = animatedTransition?.destinationContainer,
              let frame = (transitionContext?.containerView ?? modal.target.view.window)?.bounds
        else {
            return false
        }

        let distance = destinationView.frame.minY

        if (distance + velocity.y) / frame.height > 0.6 {
            return false
        }

        let initialVelocityY = max(0, distance / -velocity.y)

        let animator = UIViewPropertyAnimator(
            duration: 0.35,
            timingParameters: UISpringTimingParameters(
                dampingRatio: 1,
                initialVelocity: .init(dx: 0, dy: initialVelocityY)
            )
        )

        animator.addAnimations {
            destinationView.frame = frame
        }

        animator.startAnimation()

        return true
    }

    // MARK: UIViewControllerInteractiveTransitioning

    open func startInteractiveTransition(_ transitionContext: any UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext

        animatedTransition.animateTransition(using: transitionContext)

        isTransitioning = true

        animatedTransition?.interruptibleAnimator?.addCompletion { [weak self] _ in
            self?.isTransitioning = false
        }

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
