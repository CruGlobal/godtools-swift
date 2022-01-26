//
//  MobileContentViewWidth.swift
//  godtools
//
//  Created by Levi Eggert on 1/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

enum MobileContentViewWidth {
    
    case percentageOfContainer(value: CGFloat)
    case points(value: CGFloat)
    
    init(dimension: GodToolsToolParser.Dimension) {
        
        if let percent = dimension as? GodToolsToolParser.Dimension.Percent {
            self = .percentageOfContainer(value: CGFloat(percent.value))
        }
        else if let pixels = dimension as? GodToolsToolParser.Dimension.Pixels {
            self = .points(value: CGFloat(pixels.value))
        }
        else {
            self = .percentageOfContainer(value: 1)
        }
    }
}
