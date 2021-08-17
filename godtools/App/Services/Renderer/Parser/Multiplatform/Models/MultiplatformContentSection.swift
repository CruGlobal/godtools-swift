//
//  MultiplatformContentSection.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentSection: ContentSectionModelType {
    
    private let section: Accordion.Section
    
    required init(section: Accordion.Section) {
        
        self.section = section
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformContentSection {
    
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
        
        if let headerText = section.header {
            childModels.append(MultiplatformContentHeader(text: headerText))
        }
                
        addContentToChildModels(childModels: &childModels, content: section.content)
        
        return childModels
    }
}
