//
//  ColorPalette.swift
//  godtools
//
//  Created by Levi Eggert on 12/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum ColorPalette {
    
    case gtBlue
    
    var color: UIColor {
        
        switch self {
        case .gtBlue:
            return UIColor(red: 59.0/255.0, green: 164.0/255.0, blue: 219.0/255.0, alpha: 1.0)
        }
    }
}
