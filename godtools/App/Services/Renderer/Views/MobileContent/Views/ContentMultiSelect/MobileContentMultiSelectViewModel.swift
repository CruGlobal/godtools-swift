//
//  MobileContentMultiSelectViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentMultiSelectViewModel: MobileContentMultiSelectViewModelType {
    
    private let multiSelectModel: Multiselect
    private let renderedPageContext: MobileContentRenderedPageContext
    
    required init(multiSelectModel: Multiselect, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.multiSelectModel = multiSelectModel
        self.renderedPageContext = renderedPageContext
    }
    
    var numberOfColumnsForOptions: Int {
        return Int(multiSelectModel.columns)
    }
}
