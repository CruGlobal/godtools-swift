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
    
    private var isSelectedFlowWatcher: MultiplatformFlowWatcher?
    
    let backgroundColor: ObservableValue<UIColor>
    
    required init(multiSelectOptionModel: ContentMultiSelectOptionModelType, rendererPageModel: MobileContentRendererPageModel) {
        
        self.multiSelectOptionModel = multiSelectOptionModel
        self.rendererPageModel = rendererPageModel
        
        backgroundColor = ObservableValue(value: multiSelectOptionModel.backgroundColor)
        
        isSelectedFlowWatcher = multiSelectOptionModel.watchIsSelected(rendererState: rendererPageModel.rendererState) { [weak self] (isSelected: Bool) in
            
            guard let weakSelf = self else {
                return
            }
            
            let backgroundColor: UIColor = isSelected ? weakSelf.multiSelectOptionModel.selectedColor : weakSelf.multiSelectOptionModel.backgroundColor
            weakSelf.backgroundColor.accept(value: backgroundColor)
        }
    }
    
    deinit {
        isSelectedFlowWatcher?.close()
    }
    
    func multiSelectOptionTapped() {
        
        multiSelectOptionModel.toggleSelected(rendererState: rendererPageModel.rendererState)
    }
}
