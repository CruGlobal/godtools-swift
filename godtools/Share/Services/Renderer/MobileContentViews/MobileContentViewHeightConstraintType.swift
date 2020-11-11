//
//  MobileContentViewHeightConstraintType.swift
//  godtools
//
//  Created by Levi Eggert on 11/11/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

enum MobileContentViewHeightConstraintType {
    
    case constrainedToChildren
    case equalToFrame
    case intrinsic
    case setToAspectRatioOfProvidedSize(size: CGSize)
}
