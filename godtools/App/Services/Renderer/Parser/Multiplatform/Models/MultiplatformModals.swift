//
//  MultiplatformModals.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformModals: ModalsModelType {
    
    private let modals: [Modal]
    
    required init(modals: [Modal]) {
        
        self.modals = modals
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformModals {
    
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
        
        for modal in modals {
            childModels.append(MultiplatformModal(modal: modal))
        }
        
        return childModels
    }
}
