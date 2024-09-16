//
//  Modal.swift
//  PullModal
//
//  Created by foyoodo on 2024/9/16.
//

import UIKit

public protocol Modal: AnyObject {

    var duration: TimeInterval { get set }

    var detent: ModalDetent { get set }

    var cornerRadius: CGFloat { get set }

    var dimmedAlpha: CGFloat { get set }
}

public enum ModalDetent: RawRepresentable, Equatable {

    case absolute(_ height: CGFloat)
    case custom(_ multiplier: Double)
    case medium
    case large
    case fullScreen

    public init?(rawValue: Double) {
        if rawValue == 1.0 {
            self = .fullScreen
        } else {
            self = .custom(rawValue)
        }
    }

    public var rawValue: Double {
        switch self {
        case .custom(let multiplier): multiplier
        case .medium: 0.5
        case .large: 0.92
        case .fullScreen: 1.0
        default: 0.0
        }
    }

    func height(in containerHeight: CGFloat) -> CGFloat {
        switch self {
        case .absolute(let height): height
        default: containerHeight * rawValue
        }
    }
}
