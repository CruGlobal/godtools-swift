//
//  MultiplatformTitle.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformTitle: TitleModelType {
    
    private let contentText: Text
    
    required init(text: Text) {
        
        self.contentText = text
    }
    
    func getTextColor() -> UIColor {
        return contentText.textColor
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformTitle {
    
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
