//
//  MobileContentParagraphViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/3/21.
//  Copyright © 2021 Cru. All rights reserved.b
//

import Foundation

class MobileContentParagraphViewModel: MobileContentParagraphViewModelType {
    
    private let paragraphModel: ContentParagraphModelType
    private let rendererPageModel: MobileContentRendererPageModel
    private let containerModel: MobileContentRenderableModelContainer?
    
    private var visibilityFlowWatcher: MobileContentFlowWatcherType?
    
    let visibilityState: ObservableValue<MobileContentViewVisibilityState> = ObservableValue(value: .visible)
    
    required init(paragraphModel: ContentParagraphModelType, rendererPageModel: MobileContentRendererPageModel, containerModel: MobileContentRenderableModelContainer?) {
        
        self.paragraphModel = paragraphModel
        self.rendererPageModel = rendererPageModel
        self.containerModel = containerModel
        
        visibilityFlowWatcher = paragraphModel.watchVisibility(rendererState: rendererPageModel.rendererState, visibilityChanged: { [weak self] (visibility: MobileContentVisibility) in
            
            let visibilityStateValue: MobileContentViewVisibilityState
            
            if visibility.isGone {
                visibilityStateValue = .gone
            }
            else if visibility.isInvisible {
                visibilityStateValue = .hidden
            }
            else {
                visibilityStateValue = .visible
            }
            
            self?.visibilityState.accept(value: visibilityStateValue)
        })
    }
}
