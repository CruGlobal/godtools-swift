//
//  MultiplatformParagraph.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformParagraph: ContentParagraphModelType {
    
    private let paragraph: Paragraph
    
    required init(paragraph: Paragraph) {
        
        self.paragraph = paragraph
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformParagraph {
    
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
                
        addContentToChildModels(childModels: &childModels, content: paragraph.content)
        
        return childModels
    }
}
