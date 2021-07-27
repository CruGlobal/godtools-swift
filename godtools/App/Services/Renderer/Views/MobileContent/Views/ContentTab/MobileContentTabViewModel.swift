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
    private let rendererPageModel: MobileContentRendererPageModel
    private let mobileContentAnalytics: MobileContentAnalytics
    
    required init(tabModel: ContentTabModelType, rendererPageModel: MobileContentRendererPageModel, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.tabModel = tabModel
        self.rendererPageModel = rendererPageModel
        self.mobileContentAnalytics = mobileContentAnalytics
    }
    
    var labelText: String? {
        return tabModel.text
    }
    
    var tabListeners: [String] {
        return tabModel.listeners
    }
    
    func tabTapped() {
        mobileContentAnalytics.trackEvents(events: tabModel.getAnalyticsEvents(), rendererPageModel: rendererPageModel)
    }
}
