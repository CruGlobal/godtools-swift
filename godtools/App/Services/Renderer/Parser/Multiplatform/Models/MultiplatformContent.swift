//
//  MultiplatformContent.swift
//  godtools
//
//  Created by Levi Eggert on 8/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContent {
    
    private let content: [Content]
    
    let contentInsets: UIEdgeInsets
    let itemSpacing: CGFloat
    let scrollIsEnabled: Bool
    
    required init(content: [Content], contentInsets: UIEdgeInsets, itemSpacing: CGFloat, scrollIsEnabled: Bool) {
        
        self.content = content
        self.contentInsets = contentInsets
        self.itemSpacing = itemSpacing
        self.scrollIsEnabled = scrollIsEnabled
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformContent: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
        
        var childModels: [MobileContentRenderableModel] = Array()
        
        addContentToChildModels(childModels: &childModels, content: content)
        
        return childModels
    }
}
