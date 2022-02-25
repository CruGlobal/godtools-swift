//
//  Form+MobileContentRenderableModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

extension Form: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [Any] {
        return content
    }
}
