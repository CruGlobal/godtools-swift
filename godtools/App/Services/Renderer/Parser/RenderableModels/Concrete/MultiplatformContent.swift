//
//  MultiplatformContent.swift
//  godtools
//
//  Created by Levi Eggert on 8/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MultiplatformContent {
    
    let content: [Content]
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
    
    func getRenderableChildModels() -> [AnyObject] {
        
        return content
    }
}
