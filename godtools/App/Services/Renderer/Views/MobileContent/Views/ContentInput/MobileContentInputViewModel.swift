//
//  MobileContentInputViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentInputViewModel: MobileContentInputViewModelType {
    
    private let inputModel: Input
    private let renderedPageContext: MobileContentRenderedPageContext
    private let fontService: FontService
    
    private var inputValue: String?
    
    let inputLabel: String?
    let placeholder: String?
    
    required init(inputModel: Input, renderedPageContext: MobileContentRenderedPageContext, fontService: FontService) {
        
        self.inputModel = inputModel
        self.renderedPageContext = renderedPageContext
        self.fontService = fontService
        
        inputLabel = inputModel.label?.text
        placeholder = inputModel.placeholder?.text
    }
    
    var isHidden: Bool {
        return inputModel.type == .hidden
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
        
        if inputModel.type == .hidden {
            return inputModel.value
        }
        
        return inputValue
    }
}
