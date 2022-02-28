//
//  MobileContentMultiSelectOptionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentMultiSelectOptionViewModel: MobileContentMultiSelectOptionViewModelType {
    
    private let multiSelectOptionModel: Multiselect.Option
    private let renderedPageContext: MobileContentRenderedPageContext
    private let mobileContentAnalytics: MobileContentAnalytics
    
    private var isSelectedFlowWatcher: FlowWatcher?
    
    let backgroundColor: ObservableValue<UIColor>
    
    required init(multiSelectOptionModel: Multiselect.Option, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.multiSelectOptionModel = multiSelectOptionModel
        self.renderedPageContext = renderedPageContext
        self.mobileContentAnalytics = mobileContentAnalytics
        
        backgroundColor = ObservableValue(value: multiSelectOptionModel.backgroundColor)
        
        isSelectedFlowWatcher = multiSelectOptionModel.watchIsSelected(state: renderedPageContext.rendererState) { [weak self] (isSelected: KotlinBoolean) in

            guard let weakSelf = self else {
                return
            }
            
            let backgroundColor: UIColor = isSelected.boolValue ? weakSelf.multiSelectOptionModel.selectedColor : weakSelf.multiSelectOptionModel.backgroundColor
            
            weakSelf.backgroundColor.accept(value: backgroundColor)
        }
    }
    
    deinit {
        isSelectedFlowWatcher?.close()
    }
    
    func multiSelectOptionTapped() {
        
        multiSelectOptionModel.toggleSelected(state: renderedPageContext.rendererState)
                                
        mobileContentAnalytics.trackEvents(events: multiSelectOptionModel.getAnalyticsEvents(type: .clicked), renderedPageContext: renderedPageContext)
    }
}
