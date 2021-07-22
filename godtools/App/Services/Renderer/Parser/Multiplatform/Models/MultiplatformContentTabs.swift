//
//  MultiplatformContentTabs.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentTabs: ContentTabsModelType {
    
    private let tabs: Tabs
    
    required init(tabs: Tabs) {
        
        self.tabs = tabs
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformContentTabs {
    
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
