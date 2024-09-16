//
//  PullModalCompatible.swift
//  PullModal
//
//  Created by foyoodo on 2024/9/16.
//

import UIKit

public protocol PullModalCompatible: AnyObject { }

extension PullModalCompatible {

    public var pullModal: PullModal<Self> {
        get { PullModal(self) }
        set { }
    }
}

extension UIViewController: PullModalCompatible { }
