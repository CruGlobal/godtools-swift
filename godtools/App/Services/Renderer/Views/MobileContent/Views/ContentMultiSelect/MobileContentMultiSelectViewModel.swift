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
    private let rendererPageModel: MobileContentRendererPageModel
    
    required init(multiSelectModel: Multiselect, rendererPageModel: MobileContentRendererPageModel) {
        
        self.multiSelectModel = multiSelectModel
        self.rendererPageModel = rendererPageModel
    }
    
    var numberOfColumnsForOptions: Int {
        return Int(multiSelectModel.columns)
    }
}
