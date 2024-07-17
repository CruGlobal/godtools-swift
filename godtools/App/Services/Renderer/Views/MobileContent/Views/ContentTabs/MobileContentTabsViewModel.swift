//
//  MobileContentTabsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentTabsViewModel: MobileContentViewModel {
    
    private let tabsModel: Tabs
        
    init(tabsModel: Tabs, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics) {
        
        self.tabsModel = tabsModel
        
        super.init(baseModel: tabsModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        return UISemanticContentAttribute.from(languageDirection: renderedPageContext.language.direction)
    }
}
