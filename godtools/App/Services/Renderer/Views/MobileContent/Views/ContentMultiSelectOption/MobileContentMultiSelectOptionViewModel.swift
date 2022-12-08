//
//  MobileContentMultiSelectOptionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentMultiSelectOptionViewModel: MobileContentViewModel {
    
    private let multiSelectOptionModel: Multiselect.Option
    private let mobileContentAnalytics: MobileContentAnalytics
    
    private var isSelectedFlowWatcher: FlowWatcher?
    
    let backgroundColor: ObservableValue<UIColor>
    let hidesShadow: Bool
    
    init(multiSelectOptionModel: Multiselect.Option, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.multiSelectOptionModel = multiSelectOptionModel
        self.mobileContentAnalytics = mobileContentAnalytics
        
        backgroundColor = ObservableValue(value: multiSelectOptionModel.backgroundColor)
        
        hidesShadow = multiSelectOptionModel.style == .flat
        
        super.init(baseModel: multiSelectOptionModel, renderedPageContext: renderedPageContext)
        
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
}

// MARK: - Inputs

extension MobileContentMultiSelectOptionViewModel {
    
    func multiSelectOptionTapped() {
        
        multiSelectOptionModel.toggleSelected(state: renderedPageContext.rendererState)
                                
        mobileContentAnalytics.trackEvents(events: multiSelectOptionModel.getAnalyticsEvents(type: .clicked), renderedPageContext: renderedPageContext)
    }
}
