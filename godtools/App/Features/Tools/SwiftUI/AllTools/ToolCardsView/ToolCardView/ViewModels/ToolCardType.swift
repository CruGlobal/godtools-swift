//
//  ToolCardType.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

enum ToolCardType {
    case standard
    case standardWithNavButtons
    case square
    case squareWithNavButtons
    
    var isSquareLayout: Bool {
        switch self {
        case .standard, .standardWithNavButtons:
            return false
        case .square, .squareWithNavButtons:
            return true
        }
    }
    
    var isStandardLayout: Bool {
        return isSquareLayout == false
    }
}
