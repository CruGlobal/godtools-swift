//
//  ApplicationLayoutDirection.swift
//  godtools
//
//  Created by Levi Eggert on 9/15/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

enum ApplicationLayoutDirection {
    
    case leftToRight
    case rightToLeft
    
    var layoutDirection: LayoutDirection {
        switch self {
        case .leftToRight:
            return .leftToRight
        case .rightToLeft:
            return .rightToLeft
        }
    }
    
    var semanticContentAttribute: UISemanticContentAttribute {
        switch self {
        case .leftToRight:
            return .forceLeftToRight
        case .rightToLeft:
            return .forceRightToLeft
        }
    }
}
