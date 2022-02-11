//
//  MobileContentStyles.swift
//  godtools
//
//  Created by Levi Eggert on 7/19/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

protocol MobileContentStyles {
    
    var buttonColor: MobileContentColor? { get }
    var buttonStyle: Button.Style? { get }
    var primaryColor: MobileContentColor? { get }
    var primaryTextColor: MobileContentColor? { get }
    var textAlignment: MobileContentTextAlignment? { get }
    var textColor: MobileContentColor? { get }
}

