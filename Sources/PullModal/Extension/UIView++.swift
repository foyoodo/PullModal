//
//  UIView++.swift
//  PullModal
//
//  Created by foyoodo on 2024/9/7.
//

import UIKit

extension UIView {

    @discardableResult
    func setCornerRadius(_ cornerRadius: CGFloat) -> Self {
        layer.cornerRadius = cornerRadius
        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
        }
        return self
    }

    func adjustMasksToBounds() {
        layer.masksToBounds = layer.cornerRadius > 0
    }
}
