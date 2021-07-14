//
//  MobileContentTabsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentTabsViewModel: MobileContentTabsViewModelType {
    
    private let tabsModel: ContentTabsModelType
    private let pageModel: MobileContentRendererPageModel
        
    required init(tabsModel: ContentTabsModelType, pageModel: MobileContentRendererPageModel) {
        
        self.tabsModel = tabsModel
        self.pageModel = pageModel
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        return pageModel.language.languageDirection.semanticContentAttribute
    }
}
