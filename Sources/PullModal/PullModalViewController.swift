//
//  PullModalViewController.swift
//  PullModal
//
//  Created by foyoodo on 2024/9/6.
//

import UIKit

public protocol PullModalViewController: UIViewController {

    var mainScrollView: UIScrollView? { get }
}

extension PullModalViewController {

    public var mainScrollView: UIScrollView? { nil }
}
