//
//  TargetPullModal.swift
//  PullModal
//
//  Created by foyoodo on 2024/9/16.
//

import UIKit

@dynamicMemberLookup
public struct TargetPullModal<Base: AnyObject, Target: PullModalViewController> {

    let modal: PullModal<Base>

    public weak var target: Target!

    init(_ modal: PullModal<Base>, target: Target) {
        self.modal = modal
        self.target = target
    }

    public subscript<Property>(dynamicMember keyPath: ReferenceWritableKeyPath<PullModal<Base>, Property>) -> Property {
        get { modal[keyPath: keyPath] }
        set { modal[keyPath: keyPath] = newValue }
    }

    public subscript<Property>(dynamicMember keyPath: KeyPath<PullModal<Base>, Property>) -> Property {
        modal[keyPath: keyPath]
    }
}
