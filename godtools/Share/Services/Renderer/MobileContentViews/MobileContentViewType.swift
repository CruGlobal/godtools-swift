//
//  MobileContentViewType.swift
//  godtools
//
//  Created by Levi Eggert on 11/11/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol MobileContentViewType {
    
    var view: UIView { get }
    var heightConstraintType: MobileContentViewHeightConstraintType { get }
}
