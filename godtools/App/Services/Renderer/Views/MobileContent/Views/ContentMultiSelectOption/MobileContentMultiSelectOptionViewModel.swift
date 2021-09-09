//
//  MobileContentMultiSelectOptionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentMultiSelectOptionViewModel: MobileContentMultiSelectOptionViewModelType {
    
    private let multiSelectOptionModel: ContentMultiSelectOptionModelType
    private let rendererPageModel: MobileContentRendererPageModel
    
    let backgroundColor: ObservableValue<UIColor>
    
    required init(multiSelectOptionModel: ContentMultiSelectOptionModelType, rendererPageModel: MobileContentRendererPageModel) {
        
        self.multiSelectOptionModel = multiSelectOptionModel
        self.rendererPageModel = rendererPageModel
        
        backgroundColor = ObservableValue(value: multiSelectOptionModel.backgroundColor)
    }
    
    func multiSelectOptionTapped() {
        
        multiSelectOptionModel.toggleSelected(rendererState: rendererPageModel.rendererState)
    }
}
