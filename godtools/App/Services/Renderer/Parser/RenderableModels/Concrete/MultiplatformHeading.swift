//
//  MultiplatformHeading.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsShared

class MultiplatformHeading {
    
    let text: Text
    
    init(text: Text) {
        
        self.text = text
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformHeading: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [AnyObject] {
        
        var childModels: [AnyObject] = Array()
                
        childModels.append(text)
        
        return childModels
    }
}
