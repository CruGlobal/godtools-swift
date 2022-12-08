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
    private let renderedPageContext: MobileContentRenderedPageContext
        
    init(tabsModel: Tabs, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.tabsModel = tabsModel
        self.renderedPageContext = renderedPageContext
        
        super.init(baseModel: tabsModel)
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        return renderedPageContext.language.languageDirection.semanticContentAttribute
    }
}
