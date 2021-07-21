//
//  MultiplatformModal.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformModal: ModalModelType {
    
    required init() {
        
    }
    
    var dismissListeners: [String] {
        return [] // TODO: Set this. ~Levi
    }
    
    var listeners: [String] {
        return [] // TODO: Set this. ~Levi
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformModal {
    
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
        return Array()
    }
}
