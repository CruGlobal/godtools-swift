//
//  MultiplatformCallToAction.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformCallToAction: CallToActionModelType {
    
    private let callToAction: CallToAction
    
    required init(callToAction: CallToAction) {
        
        self.callToAction = callToAction
    }
    
    var text: String? {
        return nil // TODO: Need to set this. ~Levi
    }
    
    func getTextColor() -> MobileContentColor? {
        return nil // TODO: Need to set this. ~Levi
    }
    
    func getControlColor() -> MobileContentColor? {
        return MobileContentColor(color: callToAction.controlColor)
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformCallToAction {
    
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
