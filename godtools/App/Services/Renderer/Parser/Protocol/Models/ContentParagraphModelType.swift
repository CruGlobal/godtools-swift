//
//  ContentParagraphModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

protocol ContentParagraphModelType: MobileContentRenderableModel {
    
    func watchVisibility(rendererState: State, visibilityChanged: @escaping ((_ visibility: MobileContentVisibility) -> Void)) -> FlowWatcher
}

extension ContentParagraphModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
