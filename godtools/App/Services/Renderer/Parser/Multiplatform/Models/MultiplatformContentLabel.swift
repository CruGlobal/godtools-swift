//
//  MultiplatformContentLabel.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentLabel: ContentLabelModelType {
    
    private let text: Text
    
    required init(text: Text) {
   
        self.text = text
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformContentLabel {
    
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
        
        childModels.append(MultiplatformContentText(text: text))
        
        return childModels
    }
}
