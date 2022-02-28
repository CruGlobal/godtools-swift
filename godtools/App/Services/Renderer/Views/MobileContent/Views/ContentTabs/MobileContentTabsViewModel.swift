//
//  MobileContentTabsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentTabsViewModel: MobileContentTabsViewModelType {
    
    private let tabsModel: Tabs
    private let renderedPageContext: MobileContentRenderedPageContext
        
    required init(tabsModel: Tabs, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.tabsModel = tabsModel
        self.renderedPageContext = renderedPageContext
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        return renderedPageContext.language.languageDirection.semanticContentAttribute
    }
}
