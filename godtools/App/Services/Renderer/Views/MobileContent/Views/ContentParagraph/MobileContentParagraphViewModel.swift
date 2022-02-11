//
//  MobileContentParagraphViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/3/21.
//  Copyright © 2021 Cru. All rights reserved.b
//

import Foundation
import GodToolsToolParser

class MobileContentParagraphViewModel: MobileContentParagraphViewModelType {
    
    private let paragraphModel: Paragraph
    private let rendererPageModel: MobileContentRendererPageModel
    private let containerModel: MobileContentRenderableModelContainer?
    
    private var visibilityFlowWatcher: FlowWatcher?
    
    let visibilityState: ObservableValue<MobileContentViewVisibilityState> = ObservableValue(value: .visible)
    
    required init(paragraphModel: Paragraph, rendererPageModel: MobileContentRendererPageModel, containerModel: MobileContentRenderableModelContainer?) {
        
        self.paragraphModel = paragraphModel
        self.rendererPageModel = rendererPageModel
        self.containerModel = containerModel
                
        visibilityFlowWatcher = paragraphModel.watchVisibility(state: rendererPageModel.rendererState) { [weak self] (invisible: KotlinBoolean, gone: KotlinBoolean) in
                
            let visibilityStateValue: MobileContentViewVisibilityState
            
            if gone.boolValue {
                visibilityStateValue = .gone
            }
            else if invisible.boolValue {
                visibilityStateValue = .hidden
            }
            else {
                visibilityStateValue = .visible
            }
            
            self?.visibilityState.accept(value: visibilityStateValue)
        }
    }
    
    deinit {
        visibilityFlowWatcher?.close()
    }
}
