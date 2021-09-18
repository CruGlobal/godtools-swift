//
//  MobileContentMultiSelectViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentMultiSelectViewModel: MobileContentMultiSelectViewModelType {
    
    private let multiSelectModel: ContentMultiSelectModelType
    private let rendererPageModel: MobileContentRendererPageModel
    
    required init(multiSelectModel: ContentMultiSelectModelType, rendererPageModel: MobileContentRendererPageModel) {
        
        self.multiSelectModel = multiSelectModel
        self.rendererPageModel = rendererPageModel
    }
    
    var numberOfColumnsForOptions: Int {
        return Int(multiSelectModel.numberOfColumns)
    }
}
