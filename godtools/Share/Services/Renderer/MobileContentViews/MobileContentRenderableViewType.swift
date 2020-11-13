//
//  MobileContentRenderableViewType.swift
//  godtools
//
//  Created by Levi Eggert on 11/11/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol MobileContentRenderableViewType {
    
    var view: UIView { get }
    var heightConstraintType: MobileContentViewHeightConstraintType { get }
}
