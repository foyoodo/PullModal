//
//  PullModalPresentationController.swift
//  PullModal
//
//  Created by foyoodo on 2024/9/6.
//

import UIKit

open class PullModalPresentationController<Base: AnyObject, Target: PullModalViewController>: UIPresentationController {

    public let modal: TargetPullModal<Base, Target>

    private lazy var dimmedView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(min(1, modal.dimmedAlpha))
        view.alpha = 0
        return view
    }()

    private var shouldDimmed: Bool { modal.dimmedAlpha > 0 }

    open override var frameOfPresentedViewInContainerView: CGRect {
        guard let bounds = containerView?.bounds else { return .zero }
        let height = min(bounds.height, modal.detent.height(in: bounds.height))
        let frame = CGRect(
            x: 0,
            y: bounds.height - height,
            width: bounds.width,
            height: height
        )
        return frame
    }

    open override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        if modal.detent != .fullScreen {
            presentedView?.layer.maskedCorners = .minY
            presentedView?.setCornerRadius(modal.cornerRadius).adjustMasksToBounds()
        }

        prepareForDimmed(operation: .present)
    }

    open override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        prepareForDimmed(operation: .dismiss)
    }

    public init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        modal: TargetPullModal<Base, Target>
    ) {
        self.modal = modal
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate { [self] context in
            if shouldDimmed { dimmedView.frame = context.containerView.bounds }
        }
    }

    open func prepareForDimmed(operation: PresentationOperation) {
        guard shouldDimmed,
              let containerView,
              let transitionCoordinator = presentedViewController.transitionCoordinator
        else { return }

        switch operation {
        case .present:
            containerView.addSubview(dimmedView)
            dimmedView.frame = containerView.bounds

            transitionCoordinator.animate { [self] _ in
                dimmedView.alpha = 1
            }
        case .dismiss:
            transitionCoordinator.animate { [self] _ in
                dimmedView.alpha = 0
            }
        }
    }
}
