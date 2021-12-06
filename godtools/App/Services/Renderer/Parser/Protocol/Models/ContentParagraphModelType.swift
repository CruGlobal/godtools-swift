//
//  ContentParagraphModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ContentParagraphModelType: MobileContentRenderableModel {
    
    func watchVisibility(rendererState: MobileContentMultiplatformState, visibilityChanged: @escaping ((_ visibility: MobileContentVisibility) -> Void)) -> MobileContentFlowWatcherType
}

extension ContentParagraphModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
