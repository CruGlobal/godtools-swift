//
//  MobileContentBackgroundImageScale.swift
//  godtools
//
//  Created by Levi Eggert on 11/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

enum MobileContentBackgroundImageScale: String {
    
    case fit = "fit"
    case fill = "fill"
    case fillHorizontally = "fill-x"
    case fillVertically = "fill-y"
    
    init(imageScale: ImageScaleType) {
        
        switch imageScale {
        case .fit:
            self = .fit
        case .fill:
            self =  .fill
        case .fillX:
            self =  .fillHorizontally
        case .fillY:
            self =  .fillVertically
        default:
            assertionFailure("Found unsupported type, returning fill.  Ensure case is supported.")
            self =  .fill
        }
    }
}
