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
    private let renderedPageContext: MobileContentRenderedPageContext
    
    private var visibilityFlowWatcher: FlowWatcher?
    
    let visibilityState: ObservableValue<MobileContentViewVisibilityState> = ObservableValue(value: .visible)
    
    required init(paragraphModel: Paragraph, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.paragraphModel = paragraphModel
        self.renderedPageContext = renderedPageContext
                
        visibilityFlowWatcher = paragraphModel.watchVisibility(state: renderedPageContext.rendererState) { [weak self] (invisible: KotlinBoolean, gone: KotlinBoolean) in
                
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
