//
//  MobileContentStyles.swift
//  godtools
//
//  Created by Levi Eggert on 7/19/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol MobileContentStyles {
    
    var buttonColor: MobileContentColor? { get }
    var buttonStyle: MobileContentButtonStyle? { get }
    var primaryColor: MobileContentColor? { get }
    var primaryTextColor: MobileContentColor? { get }
    var textAlignment: MobileContentTextAlignment? { get }
    var textColor: MobileContentColor? { get }
}
