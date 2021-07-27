//
//  MultiplatformContentSpacer.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentSpacer: ContentSpacerModelType {
    
    private let spacer: Spacer
    
    required init(spacer: Spacer) {
        self.spacer = spacer
    }
    
    var height: Int32 {
        return spacer.height
    }
    
    var mode: MobileContentSpacerMode {
        switch spacer.mode {
        case .auto_:
            return .auto
        case .fixed:
            return .fixed
        default:
            assertionFailure("Returning unsupported mode for spacer.mode.  Ensure all values are supported for spacer.mode enum values.")
            return .auto
        }
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformContentSpacer {
    
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
