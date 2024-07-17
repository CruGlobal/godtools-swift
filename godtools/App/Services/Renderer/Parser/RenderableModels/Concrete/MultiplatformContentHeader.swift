//
//  MultiplatformContentHeader.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentHeader {
    
    let text: Text
    
    init(text: Text) {
        
        self.text = text
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformContentHeader: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [AnyObject] {
        
        var childModels: [AnyObject] = Array()
        
        childModels.append(text)
        
        return childModels
    }
}
 
