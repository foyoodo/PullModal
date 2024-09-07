//
//  CACornerMask++.swift
//  PullModal
//
//  Created by foyoodo on 2024/9/7.
//

import QuartzCore

extension CACornerMask {

    static var all: CACornerMask {
        [ layerMinXMinYCorner, layerMinXMaxYCorner,
          layerMaxXMinYCorner, layerMaxXMaxYCorner ]
    }

    static var minY: CACornerMask {
        [ layerMinXMinYCorner, layerMaxXMinYCorner ]
    }
}
