//
//  LegacyMobileContentMultiSelectOptionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsShared

class LegacyMobileContentMultiSelectOptionViewModel: LegacyMobileContentViewModel {
    
    private let multiSelectOptionModel: Multiselect.Option
    private let mobileContentAnalytics: MobileContentRendererAnalytics
    
    private var isSelectedFlowWatcher: FlowWatcher?
    
    let backgroundColor: ObservableValue<UIColor>
    let hidesShadow: Bool
    
    init(
        multiSelectOptionModel: Multiselect.Option,
        renderedPageContext: MobileContentRenderedPageContext,
        mobileContentAnalytics: MobileContentRendererAnalytics
    ) {
        
        self.multiSelectOptionModel = multiSelectOptionModel
        self.mobileContentAnalytics = mobileContentAnalytics
        
        backgroundColor = ObservableValue(value: multiSelectOptionModel.backgroundColor.toUIColor())

        hidesShadow = multiSelectOptionModel.style == .flat
        
        super.init(baseModel: multiSelectOptionModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
        
        isSelectedFlowWatcher = multiSelectOptionModel.watchIsSelected(ctx: renderedPageContext.rendererState) { [weak self] (isSelected: KotlinBoolean) in

            guard let weakSelf = self else {
                return
            }
            
            let backgroundColor: UIColor = isSelected.boolValue ? weakSelf.multiSelectOptionModel.selectedColor.toUIColor() : weakSelf.multiSelectOptionModel.backgroundColor.toUIColor()

            weakSelf.backgroundColor.accept(value: backgroundColor)
        }
    }
    
    deinit {
        isSelectedFlowWatcher?.close()
    }
}

// MARK: - Inputs

extension LegacyMobileContentMultiSelectOptionViewModel {
    
    func multiSelectOptionTapped() {
        
        multiSelectOptionModel.toggleSelected(ctx: renderedPageContext.rendererState)
                
        Task {
                
            try await mobileContentAnalytics.trackEvents(
                events: multiSelectOptionModel.getAnalyticsEvents(type: .clicked),
                renderedPageContext: renderedPageContext
            )
        }
    }
}
