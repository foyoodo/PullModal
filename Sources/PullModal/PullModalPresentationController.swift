//
//  PullModalPresentationController.swift
//  PullModal
//
//  Created by foyoodo on 2024/9/6.
//

import UIKit

open class PullModalPresentationController<Base: AnyObject, Target: PullModalViewController>: UIPresentationController {

    public let modal: TargetPullModal<Base, Target>

    public init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        modal: TargetPullModal<Base, Target>
    ) {
        self.modal = modal
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
}
