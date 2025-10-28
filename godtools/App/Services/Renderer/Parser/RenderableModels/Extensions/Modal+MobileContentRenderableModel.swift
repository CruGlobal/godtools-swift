//
//  Modal+MobileContentRenderableModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsShared

extension Modal: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [AnyObject] {
        
        return content
    }
}
