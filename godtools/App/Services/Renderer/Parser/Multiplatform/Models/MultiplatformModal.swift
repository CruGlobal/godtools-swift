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
    
    private let modal: Modal
    
    required init(modal: Modal) {
        
        self.modal = modal
    }
    
    var dismissListeners: [String] {
        return modal.dismissListeners.map({$0.description()})
    }
    
    var listeners: [String] {
        return modal.listeners.map({$0.description()})
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
