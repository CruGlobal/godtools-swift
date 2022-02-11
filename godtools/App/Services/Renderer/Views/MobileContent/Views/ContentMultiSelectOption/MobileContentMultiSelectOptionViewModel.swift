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
    
    private let multiSelectOptionModel: ContentMultiSelectOptionModelType
    private let rendererPageModel: MobileContentRendererPageModel
    private let mobileContentAnalytics: MobileContentAnalytics
    
    private var isSelectedFlowWatcher: FlowWatcher?
    
    let backgroundColor: ObservableValue<UIColor>
    
    required init(multiSelectOptionModel: ContentMultiSelectOptionModelType, rendererPageModel: MobileContentRendererPageModel, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.multiSelectOptionModel = multiSelectOptionModel
        self.rendererPageModel = rendererPageModel
        self.mobileContentAnalytics = mobileContentAnalytics
        
        backgroundColor = ObservableValue(value: multiSelectOptionModel.backgroundColor)
        
        isSelectedFlowWatcher = multiSelectOptionModel.watchIsSelected(rendererState: rendererPageModel.rendererState) { [weak self] (isSelected: Bool) in
            
            guard let weakSelf = self else {
                return
            }
            
            let backgroundColor: UIColor = isSelected ? weakSelf.multiSelectOptionModel.selectedColor : weakSelf.multiSelectOptionModel.backgroundColor
            weakSelf.backgroundColor.accept(value: backgroundColor)
        }
    }
    
    deinit {
        isSelectedFlowWatcher?.close()
    }
    
    func multiSelectOptionTapped() {
        
        multiSelectOptionModel.toggleSelected(rendererState: rendererPageModel.rendererState)
        
        let analyticsEvents: [AnalyticsEventModelType] = multiSelectOptionModel.getTappedAnalyticsEvents()
                
        mobileContentAnalytics.trackEvents(events: analyticsEvents, rendererPageModel: rendererPageModel)
    }
}
