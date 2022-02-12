//
//  MultiplatformHeading.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MultiplatformHeading: HeadingModelType {
    
    private let contentText: Text
    
    required init(text: Text) {
        
        self.contentText = text
    }
    
    func getTextColor() -> UIColor {
        return contentText.textColor
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformHeading {
    
    var restrictTo: String? {
        return nil
    }
    
    var version: String? {
        return nil
    }
    
    var modelContentIsRenderable: Bool {
        return true
    }
    
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
        
        var childModels: [MobileContentRenderableModel] = Array()
                
        childModels.append(MultiplatformContentText(text: contentText))
        
        return childModels
    }
}
