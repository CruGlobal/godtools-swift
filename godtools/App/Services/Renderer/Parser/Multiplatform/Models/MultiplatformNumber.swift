//
//  MultiplatformNumber.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformNumber: NumberModelType {
    
    private let contentText: Text
    
    required init(text: Text) {
        
        self.contentText = text
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformNumber {
    
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
                
        childModels.append(MultiplatformText(text: contentText))
        
        return childModels
    }
}
