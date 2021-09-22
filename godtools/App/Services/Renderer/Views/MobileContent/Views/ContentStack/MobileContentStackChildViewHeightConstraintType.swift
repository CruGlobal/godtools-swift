//
//  MobileContentStackChildViewHeightConstraintType.swift
//  godtools
//
//  Created by Levi Eggert on 2/16/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

enum MobileContentStackChildViewHeightConstraintType {
    
    case constrainedToChildren
    case equalToHeight(height: CGFloat)
    case equalToSize(size: CGSize)
    case intrinsic
    case setToAspectRatioOfProvidedSize(size: CGSize)
    case spacer
    
    var isConstrainedByChildren: Bool {
        switch self {
        case .constrainedToChildren:
            return true
        default:
            return false
        }
    }
}
