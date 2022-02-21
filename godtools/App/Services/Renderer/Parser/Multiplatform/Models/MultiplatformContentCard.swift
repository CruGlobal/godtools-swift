//
//  MultiplatformContentCard.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentCard {
    
    private let contentCard: Card
    
    required init(contentCard: Card) {
        
        self.contentCard = contentCard
    }
    
    var events: [EventId] {
        return contentCard.events
    }
}

extension MultiplatformContentCard: MobileContentRenderableModel {
    
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
        
        let content: [Content] = contentCard.content
        
        addContentToChildModels(childModels: &childModels, content: content)
                    
        return childModels
    }
}
