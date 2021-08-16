//
//  MultiplatformContentTab.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentTab: ContentTabModelType {
    
    private let tab: Tabs.Tab
    
    required init(tab: Tabs.Tab) {
        
        self.tab = tab
    }
    
    var listeners: [String] {
        return tab.listeners.map({$0.description()})
    }
    
    var text: String? {
        return tab.label?.text
    }
    
    func getAnalyticsEvents() -> [AnalyticsEventModelType] {
        return tab.analyticsEvents.map({MultiplatformAnalyticsEvent(analyticsEvent: $0)})
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformContentTab {
    
    var restrictTo: String? {
        return nil
    }
    
    var version: String? {
        return nil
    }
    
    var modelContentIsRenderable: Bool {
        return true
    }
    
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
        
        var childModels: [MobileContentRenderableModel] = Array()

        addContentToChildModels(childModels: &childModels, content: tab.content)
                
        return childModels
    }
}
