//
//  TractPage+MobileContentRenderableModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

extension TractPage: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [Any] {
        
        var childModels: [MobileContentRenderableModel] = Array()
        
        if let header = header {
            childModels.append(header)
        }
        
        if let hero = hero {
            childModels.append(hero)
        }
        
        if cards.count > 0 {
            childModels.append(MultiplatformCards(cards: cards))
        }
        
        childModels.append(callToAction)
        
        childModels.append(MultiplatformModals(modals: modals))
        
        return childModels
    }
}
