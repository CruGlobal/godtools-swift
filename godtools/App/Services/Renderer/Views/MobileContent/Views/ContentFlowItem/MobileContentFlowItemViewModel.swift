//
//  MobileContentFlowItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentFlowItemViewModel: NSObject, MobileContentFlowItemViewModelType {
    
    private let flowItem: GodToolsToolParser.Flow.Item
    private let renderedPageContext: MobileContentRenderedPageContext
    
    private var visibilityFlowWatcher: FlowWatcher?
    
    let visibilityState: ObservableValue<MobileContentViewVisibilityState>
    
    required init(flowItem: GodToolsToolParser.Flow.Item, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.flowItem = flowItem
        self.renderedPageContext = renderedPageContext
        
        let visibility: MobileContentViewVisibilityState
        
        if flowItem.isGone(state: renderedPageContext.rendererState) {
            visibility = .gone
        }
        else if flowItem.isInvisible(state: renderedPageContext.rendererState) {
            visibility = .hidden
        }
        else {
            visibility = .visible
        }
        
        visibilityState = ObservableValue(value: visibility)
        
        super.init()
        
        visibilityFlowWatcher = flowItem.watchVisibility(state: renderedPageContext.rendererState, block: { [weak self] (invisible: KotlinBoolean, gone: KotlinBoolean) in
            
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
        })
    }
    
    deinit {
        visibilityFlowWatcher?.close()
    }
    
    var width: MobileContentViewWidth {
        
        return MobileContentViewWidth(dimension: flowItem.width)
    }
}
