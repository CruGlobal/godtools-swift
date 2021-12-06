//
//  MultiplatformContentParagraph.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentParagraph: ContentParagraphModelType {
    
    private let paragraph: Paragraph
        
    required init(paragraph: Paragraph) {
        
        self.paragraph = paragraph
    }
    
    func watchVisibility(rendererState: MobileContentMultiplatformState, visibilityChanged: @escaping ((_ visibility: MobileContentVisibility) -> Void)) -> MobileContentFlowWatcherType {
        
        let flowWatcher = paragraph.watchVisibility(state: rendererState.state) { (invisible: KotlinBoolean, gone: KotlinBoolean) in
            
            visibilityChanged(MobileContentVisibility(isInvisible: invisible.boolValue, isGone: gone.boolValue))
        }
        
        return MultiplatformFlowWatcher(flowWatcher: flowWatcher)
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformContentParagraph {
    
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
        
        addContentToChildModels(childModels: &childModels, content: paragraph.content)
        
        return childModels
    }
}
