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
    private let rendererPageModel: MobileContentRendererPageModel
    private let mobileContentAnalytics: MobileContentAnalytics
    
    private var isSelectedFlowWatcher: FlowWatcher?
    
    let backgroundColor: ObservableValue<UIColor>
    
    required init(multiSelectOptionModel: Multiselect.Option, rendererPageModel: MobileContentRendererPageModel, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.multiSelectOptionModel = multiSelectOptionModel
        self.rendererPageModel = rendererPageModel
        self.mobileContentAnalytics = mobileContentAnalytics
        
        backgroundColor = ObservableValue(value: multiSelectOptionModel.backgroundColor)
        
        isSelectedFlowWatcher = multiSelectOptionModel.watchIsSelected(state: rendererPageModel.rendererState) { [weak self] (isSelected: KotlinBoolean) in

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
        
        multiSelectOptionModel.toggleSelected(state: rendererPageModel.rendererState)
                
        let analyticsEvents: [AnalyticsEventModelType] = multiSelectOptionModel.getAnalyticsEvents(type: .clicked).map({MultiplatformAnalyticsEvent(analyticsEvent: $0)})
                
        mobileContentAnalytics.trackEvents(events: analyticsEvents, rendererPageModel: rendererPageModel)
    }
}
