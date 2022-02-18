//
//  MobileContentStyles.swift
//  godtools
//
//  Created by Levi Eggert on 7/19/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

protocol MobileContentStyles {
    
    var buttonColor: UIColor? { get }
    var buttonStyle: Button.Style? { get }
    var primaryColor: UIColor? { get }
    var primaryTextColor: UIColor? { get }
    var textAlignment: Text.Align? { get }
    var textColor: UIColor? { get }
}

