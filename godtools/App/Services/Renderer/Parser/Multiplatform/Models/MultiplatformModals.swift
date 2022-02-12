//
//  MultiplatformModals.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformModals {
    
    private let modals: [Modal]
    
    required init(modals: [Modal]) {
        
        self.modals = modals
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformModals: MobileContentRenderableModel {
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
        return modals
    }
}
