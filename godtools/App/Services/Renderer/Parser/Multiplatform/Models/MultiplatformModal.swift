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
        
        var childModels: [MobileContentRenderableModel] = Array()
        
        addContentToChildModels(childModels: &childModels, content: modal.content)
        
        return childModels
    }
}

// MARK: - MobileContentRenderableModelContainer

extension MultiplatformModal: MobileContentRenderableModelContainer {
    
    var buttonColor: MobileContentColor? {
        return MobileContentColor(color: modal.buttonColor)
    }
    
    var buttonStyle: MobileContentButtonStyle? {
        switch modal.buttonStyle {
        case .outlined:
            return .outlined
        case .contained:
            return .contained
        case .unknown:
            return nil
        default:
            assertionFailure("Found unsupported buttonStyle: \(modal.buttonStyle). Ensure all cases are supported.")
            return nil
        }
    }
    
    var primaryColor: MobileContentColor? {
        return MobileContentColor(color: modal.primaryColor)
    }
    
    var primaryTextColor: MobileContentColor? {
        return MobileContentColor(color: modal.primaryTextColor)
    }
    
    var textAlignment: MobileContentTextAlignment? {
        switch modal.textAlign {
        case .center:
            return .center
        case .start:
            return .left
        case .end:
            return .right
        default:
            assertionFailure("Found unsupported textAlign: \(modal.textAlign). Ensure all cases are supported.")
            return nil
        }
    }
    
    var textColor: MobileContentColor? {
        return MobileContentColor(color: modal.textColor)
    }
}
