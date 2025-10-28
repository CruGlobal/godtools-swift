//
//  MultiplatformContent.swift
//  godtools
//
//  Created by Levi Eggert on 8/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsShared

class MultiplatformContent {
    
    let content: [Content]
    let contentInsets: UIEdgeInsets?
    let scrollIsEnabled: Bool
    
    init(content: [Content], contentInsets: UIEdgeInsets?, scrollIsEnabled: Bool) {
        
        self.content = content
        self.contentInsets = contentInsets
        self.scrollIsEnabled = scrollIsEnabled
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformContent: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [AnyObject] {
        
        return content
    }
}
