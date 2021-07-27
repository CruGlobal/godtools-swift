//
//  MultiplatformHero.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformHero: HeroModelType {
    
    private let hero: Hero
    
    required init(hero: Hero) {
        
        self.hero = hero
    }
    
    func getAnalyticsEvents() -> [AnalyticsEventModelType] {
        // TODO: Set analytics events. ~Levi
        return Array()
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformHero {
    
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
        
        if let heading = hero.heading {
            childModels.append(MultiplatformHeading(text: heading))
        }
        
        addContentToChildModels(childModels: &childModels, content: hero.content)
             
        return childModels
    }
}
