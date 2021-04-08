//
//  MobileContentTabViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/22/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentTabViewModel: MobileContentTabViewModelType {
    
    private let tabNode: ContentTabNode
    private let pageModel: MobileContentRendererPageModel
    private let mobileContentAnalytics: MobileContentAnalytics
    
    required init(tabNode: ContentTabNode, pageModel: MobileContentRendererPageModel, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.tabNode = tabNode
        self.pageModel = pageModel
        self.mobileContentAnalytics = mobileContentAnalytics
    }
    
    var labelText: String? {
        return tabNode.contentLabelNode?.textNode?.text
    }
    
    var tabListeners: [String] {
        return tabNode.listeners
    }
    
    func tabTapped() {
        if let analyticsEventsNode = tabNode.analyticsEventsNode {
            mobileContentAnalytics.trackEvents(events: analyticsEventsNode)
        }
    }
}
