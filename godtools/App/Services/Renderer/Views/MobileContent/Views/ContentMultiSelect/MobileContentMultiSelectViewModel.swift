//
//  MobileContentMultiSelectViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentMultiSelectViewModel: MobileContentViewModel {
    
    private let multiSelectModel: Multiselect
    
    init(multiSelectModel: Multiselect, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.multiSelectModel = multiSelectModel
        
        super.init(baseModel: multiSelectModel, renderedPageContext: renderedPageContext)
    }
    
    var numberOfColumnsForOptions: Int {
        return Int(multiSelectModel.columns)
    }
}
