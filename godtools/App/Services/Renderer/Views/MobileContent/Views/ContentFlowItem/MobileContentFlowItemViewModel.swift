//
//  MobileContentFlowItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsShared

class MobileContentFlowItemViewModel: MobileContentViewModel {
    
    private let flowItem: GodToolsShared.Flow.Item
    
    private var visibilityFlowWatcher: FlowWatcher?
    
    let visibilityState: ObservableValue<MobileContentViewVisibilityState>
    
    init(flowItem: GodToolsShared.Flow.Item, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics) {
        
        self.flowItem = flowItem
        
        let visibility: MobileContentViewVisibilityState
        
        if flowItem.isGone(ctx: renderedPageContext.rendererState) {
            visibility = .gone
        }
        else if flowItem.isInvisible(ctx: renderedPageContext.rendererState) {
            visibility = .hidden
        }
        else {
            visibility = .visible
        }
        
        visibilityState = ObservableValue(value: visibility)
        
        super.init(baseModel: flowItem, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
        
        visibilityFlowWatcher = flowItem.watchVisibility(ctx: renderedPageContext.rendererState, block: { [weak self] (invisible: KotlinBoolean, gone: KotlinBoolean) in
            
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
