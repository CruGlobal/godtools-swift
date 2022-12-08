//
//  MobileContentParagraphViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/3/21.
//  Copyright © 2021 Cru. All rights reserved.b
//

import Foundation
import GodToolsToolParser

class MobileContentParagraphViewModel: MobileContentViewModel {
    
    private let paragraphModel: Paragraph
    
    private var visibilityFlowWatcher: FlowWatcher?
    
    let visibilityState: ObservableValue<MobileContentViewVisibilityState> = ObservableValue(value: .visible)
    
    init(paragraphModel: Paragraph, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.paragraphModel = paragraphModel
        
        super.init(baseModel: paragraphModel, renderedPageContext: renderedPageContext)
                
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
