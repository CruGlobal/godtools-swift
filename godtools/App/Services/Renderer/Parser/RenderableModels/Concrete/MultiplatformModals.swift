//
//  MultiplatformModals.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsShared

class MultiplatformModals {
    
    let modals: [Modal]
    
    init(modals: [Modal]) {
        
        self.modals = modals
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformModals: MobileContentRenderableModel {
    func getRenderableChildModels() -> [AnyObject] {
        return modals
    }
}
