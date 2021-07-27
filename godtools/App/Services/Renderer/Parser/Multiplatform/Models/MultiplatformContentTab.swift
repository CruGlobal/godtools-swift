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
        return [] // TODO: Set this. ~Levi
    }
    
    var text: String? {
        return tab.label?.text
    }
    
    func getAnalyticsEvents() -> [AnalyticsEventModelType] {
        return [] // TODO: Set this. ~Levi
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
        return Array()
    }
}
