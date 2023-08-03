//
//  MobileContentInputViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentInputViewModel: MobileContentViewModel {
    
    private let inputModel: Input
    private let fontService: FontService
    
    private var inputValue: String?
    
    let inputLabel: String?
    let placeholder: String?
    
    init(inputModel: Input, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics, fontService: FontService) {
        
        self.inputModel = inputModel
        self.fontService = fontService
        
        inputLabel = inputModel.label?.text
        placeholder = inputModel.placeholder?.text
        
        super.init(baseModel: inputModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
    
    var isHidden: Bool {
        return inputModel.type == .hidden
    }
    
    var isRequired: Bool {
        return inputModel.isRequired
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

// MARK: - Inputs

extension MobileContentInputViewModel {
    
    func inputChanged(text: String?) {
        inputValue = text
    }
}
