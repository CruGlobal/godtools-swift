//
//  MobileContentStackRenderedView.swift
//  godtools
//
//  Created by Levi Eggert on 11/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

// TODO: Remove this class. ~Levi
class MobileContentStackRenderedView {
    
    enum HeightConstraintType {
        
        case constrainedToChildren
        case equalToHeight(height: CGFloat)
        case equalToSize(size: CGSize)
        case intrinsic
        case setToAspectRatioOfProvidedSize(size: CGSize)
        case spacer
    }
    
    let view: UIView
    let heightConstraintType: HeightConstraintType
    
    required init(view: UIView, heightConstraintType: HeightConstraintType) {
        
        self.view = view
        self.heightConstraintType = heightConstraintType
    }
}
