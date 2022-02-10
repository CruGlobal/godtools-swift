//
//  HorizontallyCenteredCollectionViewCellSize.swift
//  godtools
//
//  Created by Levi Eggert on 1/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

enum HorizontallyCenteredCollectionViewCellSize {
    
    case aspectRatioOfContainerWidth(aspectRatio: CGSize, containerWidth: CGFloat, widthMultiplier: CGFloat?)
    case fixed(width: CGFloat, height: CGFloat)
    
    var size: CGSize {
        
        switch self {
        
        case .aspectRatioOfContainerWidth(let aspectRatio, let containerWidth, let widthMultiplier):
            
            let multiplier: CGFloat = widthMultiplier ?? 1
            let width: CGFloat = multiplier * containerWidth
            let height: CGFloat = (aspectRatio.height / aspectRatio.width) * width
            
            return CGSize(width: width, height: height)
        
        case .fixed(let width, let height):
            
            return CGSize(width: width, height: height)
        }
    }
    
    var width: CGFloat {
        return size.width
    }
    
    var height: CGFloat {
        return size.height
    }
}
