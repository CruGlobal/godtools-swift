//
//  MobileContentInputViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentInputViewModel: MobileContentInputViewModelType {
    
    private let inputModel: ContentInputModelType
    private let rendererPageModel: MobileContentRendererPageModel
    private let fontService: FontService
    
    private var inputValue: String?
    
    let inputLabel: String?
    let placeholder: String?
    
    required init(inputModel: ContentInputModelType, rendererPageModel: MobileContentRendererPageModel, fontService: FontService) {
        
        self.inputModel = inputModel
        self.rendererPageModel = rendererPageModel
        self.fontService = fontService
        
        inputLabel = inputModel.text
        placeholder = inputModel.placeholderText
    }
    
    var isHidden: Bool {
        return inputModel.inputType == .hidden
    }
    
    var isRequired: Bool {
        return inputModel.isRequired
    }
    
    func inputChanged(text: String?) {
        inputValue = text
    }
    
    func getInputName() -> String? {
        return inputModel.name
    }
    
    func getInputValue() -> String? {
        
        if inputModel.inputType == .hidden {
            return inputModel.value
        }
        
        return inputValue
    }
}
