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
    private let rendererPageModel: MobileContentRendererPageModel
    private let mobileContentAnalytics: MobileContentAnalytics
    
    required init(tabModel: Tabs.Tab, rendererPageModel: MobileContentRendererPageModel, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.tabModel = tabModel
        self.rendererPageModel = rendererPageModel
        self.mobileContentAnalytics = mobileContentAnalytics
    }
    
    var labelText: String? {
        return tabModel.label?.text
    }
    
    var tabListeners: [EventId] {
        return Array(tabModel.listeners)
    }
    
    func tabTapped() {
        let events: [AnalyticsEventModelType] = tabModel.analyticsEvents.map({MultiplatformAnalyticsEvent(analyticsEvent: $0)})
        mobileContentAnalytics.trackEvents(events: events, rendererPageModel: rendererPageModel)
    }
}
