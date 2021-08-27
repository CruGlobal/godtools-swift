//
//  MultiplatformContentFallback.swift
//  godtools
//
//  Created by Levi Eggert on 8/16/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentFallback: ContentFallbackModelType {
    
    private let fallback: Fallback
    
    required init(fallback: Fallback) {
        
        self.fallback = fallback
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformContentFallback {
    
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
        
        addContentToChildModels(childModels: &childModels, content: fallback.content)
        
        return childModels
    }
}
