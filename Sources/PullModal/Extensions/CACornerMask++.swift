//
//  CACornerMask++.swift
//  PullModal
//
//  Created by foyoodo on 2024/9/7.
//

import QuartzCore

extension CACornerMask {

    public static var all: CACornerMask {
        [ layerMinXMinYCorner, layerMinXMaxYCorner,
          layerMaxXMinYCorner, layerMaxXMaxYCorner ]
    }

    public static var minY: CACornerMask {
        [ layerMinXMinYCorner, layerMaxXMinYCorner ]
    }
}
