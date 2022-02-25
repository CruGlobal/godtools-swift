//
//  Multiselect+MobileContentRenderableModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

extension Multiselect: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [Any] {
        
        return options
    }
}
