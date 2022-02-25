//
//  Accordion+MobileContentRenderableModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

extension Accordion: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [Any] {
        
        return sections
    }
}
