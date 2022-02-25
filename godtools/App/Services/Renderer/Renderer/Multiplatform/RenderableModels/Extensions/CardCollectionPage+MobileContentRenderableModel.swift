//
//  CardCollectionPage+MobileContentRenderableModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

extension CardCollectionPage: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [Any] {
        
        return cards
    }
}
