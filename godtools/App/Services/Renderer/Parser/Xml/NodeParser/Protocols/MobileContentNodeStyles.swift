//
//  MobileContentNodeStyles.swift
//  godtools
//
//  Created by Levi Eggert on 3/26/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol MobileContentNodeStyles {
    
    var buttonColor: MobileContentRGBAColor? { get }
    var buttonStyle: MobileContentButtonStyle? { get }
    var primaryColor: MobileContentRGBAColor? { get }
    var primaryTextColor: MobileContentRGBAColor? { get }
    var textAlignment: MobileContentTextAlign? { get }
    var textColor: MobileContentRGBAColor? { get }
}
