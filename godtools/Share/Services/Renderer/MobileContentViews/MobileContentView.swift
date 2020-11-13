//
//  MobileContentView.swift
//  godtools
//
//  Created by Levi Eggert on 11/11/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentView: MobileContentRenderableViewType {
    
    let view: UIView
    let heightConstraintType: MobileContentViewHeightConstraintType
    
    required init(view: UIView, heightConstraintType: MobileContentViewHeightConstraintType) {
        
        self.view = view
        self.heightConstraintType = heightConstraintType
    }
}
