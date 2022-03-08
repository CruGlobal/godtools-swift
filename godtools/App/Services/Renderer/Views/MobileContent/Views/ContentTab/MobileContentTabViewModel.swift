//
//  MobileContentTabViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/22/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentTabViewModel: MobileContentTabViewModelType {
    
    private let tabModel: Tabs.Tab
    private let renderedPageContext: MobileContentRenderedPageContext
    private let mobileContentAnalytics: MobileContentAnalytics
    
    required init(tabModel: Tabs.Tab, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.tabModel = tabModel
        self.renderedPageContext = renderedPageContext
        self.mobileContentAnalytics = mobileContentAnalytics
    }
    
    var labelText: String? {
        return tabModel.label?.text
    }
    
    var tabListeners: [EventId] {
        return Array(tabModel.listeners)
    }
    
    func tabTapped() {
        
        mobileContentAnalytics.trackEvents(events: tabModel.analyticsEvents, renderedPageContext: renderedPageContext)
    }
}
