//
//  ApplicationLayoutDirection.swift
//  godtools
//
//  Created by Levi Eggert on 9/14/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

enum ApplicationLayoutDirection {
    
    case leftToRight
    case rightToLeft
    
    var swiftUI: LayoutDirection {
        switch self {
        case .leftToRight:
            return .leftToRight
        case .rightToLeft:
            return .rightToLeft
        }
    }
    
    var uiKit: UISemanticContentAttribute {
        switch self {
        case .leftToRight:
            return .forceLeftToRight
        case .rightToLeft:
            return .forceRightToLeft
        }
    }
}
