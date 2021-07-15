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
    private let rendererPageModel: MobileContentRendererPageModel
        
    required init(tabsModel: ContentTabsModelType, rendererPageModel: MobileContentRendererPageModel) {
        
        self.tabsModel = tabsModel
        self.rendererPageModel = rendererPageModel
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        return rendererPageModel.language.languageDirection.semanticContentAttribute
    }
}
