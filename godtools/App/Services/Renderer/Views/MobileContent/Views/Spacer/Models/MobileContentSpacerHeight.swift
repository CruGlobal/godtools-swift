//
//  MobileContentSpacerHeight.swift
//  godtools
//
//  Created by Levi Eggert on 2/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

enum MobileContentSpacerHeight {
    
    case auto
    case fixed(height: CGFloat)
    
    var isAuto: Bool {
        switch self {
        case .auto:
            return true
        default:
            return false
        }
    }
    
    var fixedHeightValue: CGFloat {
        switch self {
        case .fixed(let height):
            return height
        default:
            return 0
        }
    }
}
