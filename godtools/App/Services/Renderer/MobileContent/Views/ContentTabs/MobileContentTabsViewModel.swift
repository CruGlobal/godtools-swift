//
//  MobileContentTabsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentTabsViewModel: MobileContentTabsViewModelType {
    
    private let tabsNode: ContentTabsNode
    private let pageModel: MobileContentRendererPageModel
        
    required init(tabsNode: ContentTabsNode, pageModel: MobileContentRendererPageModel) {
        
        self.tabsNode = tabsNode
        self.pageModel = pageModel
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        return pageModel.languageDirectionSemanticContentAttribute
    }
}
