//
//  MultiplatformHeading.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MultiplatformHeading {
    
    private let contentText: Text
    
    required init(text: Text) {
        
        self.contentText = text
    }
    
    func getTextColor() -> UIColor {
        return contentText.textColor
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformHeading: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
        
        var childModels: [MobileContentRenderableModel] = Array()
                
        childModels.append(MultiplatformContentText(text: contentText))
        
        return childModels
    }
}
