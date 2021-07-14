//
//  MobileContentTabViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/22/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentTabViewModel: MobileContentTabViewModelType {
    
    private let tabModel: ContentTabModelType
    private let pageModel: MobileContentRendererPageModel
    private let mobileContentAnalytics: MobileContentAnalytics
    
    required init(tabModel: ContentTabModelType, pageModel: MobileContentRendererPageModel, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.tabModel = tabModel
        self.pageModel = pageModel
        self.mobileContentAnalytics = mobileContentAnalytics
    }
    
    var labelText: String? {
        return tabModel.text
    }
    
    var tabListeners: [String] {
        return tabModel.listeners
    }
    
    func tabTapped() {
        mobileContentAnalytics.trackEvents(events: tabModel.getAnalyticsEvents(), page: pageModel)
    }
}
