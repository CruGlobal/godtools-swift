//
//  MobileContentStackChildViewType.swift
//  godtools
//
//  Created by Levi Eggert on 2/16/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol MobileContentStackChildViewType: AnyObject {
    
    var view: UIView { get }
    var contentStackHeightConstraintType: MobileContentStackChildViewHeightConstraintType { get }
}
