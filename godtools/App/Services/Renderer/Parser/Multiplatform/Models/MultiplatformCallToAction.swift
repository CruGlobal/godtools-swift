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
        return callToAction.label?.text
    }
    
    func getTextColor() -> MobileContentColor? {
        
        guard let textColor = callToAction.label?.textColor else {
            return nil
        }

        return MobileContentColor(color: textColor)
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
