//
//  MultiplatformContentAccordion.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentAccordion: ContentAccordionModelType {
    
    private let accordion: Accordion
    
    required init(accordion: Accordion) {
        
        self.accordion = accordion
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformContentAccordion {
    
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
        
        for section in accordion.sections {
            childModels.append(MultiplatformContentSection(section: section))
        }
        
        return childModels
    }
}
