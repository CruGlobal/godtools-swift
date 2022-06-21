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
    case spotlight
    case favorites
    
    var isSquareLayout: Bool {
        switch self {
        case .standard:
            return false
        case .spotlight, .favorites:
            return true
        }
    }
    
    var isFavorites: Bool {
        switch self {
        case .favorites:    return true
        default:            return false
        }
    }
}
