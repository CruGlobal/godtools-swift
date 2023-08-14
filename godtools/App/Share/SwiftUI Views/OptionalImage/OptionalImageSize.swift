//
//  OptionalImageSize.swift
//  godtools
//
//  Created by Levi Eggert on 8/14/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

enum OptionalImageSize {
    
    case aspectRatio(width: CGFloat, aspectRatio: CGSize)
    case fixed(width: CGFloat, height: CGFloat)
    
    var width: CGFloat {
        
        switch self {
        
        case .aspectRatio(let width, _):
            return width
            
        case .fixed(let width, _):
            return width
        }
    }
    
    var height: CGFloat {
        
        switch self {
        
        case .aspectRatio(let width, let aspectRatio):
            let height: CGFloat = floor((width / aspectRatio.width) * aspectRatio.height)
            return height
            
        case .fixed( _, let height):
            return height
        }
    }
}
