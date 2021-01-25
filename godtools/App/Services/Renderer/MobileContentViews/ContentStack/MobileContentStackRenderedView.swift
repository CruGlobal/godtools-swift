//
//  MobileContentStackRenderedView.swift
//  godtools
//
//  Created by Levi Eggert on 11/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentStackRenderedView: MobileContentRenderableView {
    
    enum HeightConstraintType {
        
        case constrainedToChildren
        case equalToHeight(height: CGFloat)
        case equalToSize(size: CGSize)
        case intrinsic
        case setToAspectRatioOfProvidedSize(size: CGSize)
    }
    
    let view: UIView
    let heightConstraintType: HeightConstraintType
    
    required init(view: UIView, heightConstraintType: HeightConstraintType) {
        
        self.view = view
        self.heightConstraintType = heightConstraintType
    }
    
    func addRenderableView(renderableView: MobileContentRenderableView) {
        
    }
}
