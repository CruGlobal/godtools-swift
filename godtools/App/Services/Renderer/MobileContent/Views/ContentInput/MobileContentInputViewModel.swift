//
//  MobileContentInputViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentInputViewModel: MobileContentInputViewModelType {
    
    private let inputNode: ContentInputNode
    private let pageModel: MobileContentRendererPageModel
    private let fontService: FontService
    
    private var inputValue: String?
    
    let inputLabel: String?
    let placeholder: String?
    
    required init(inputNode: ContentInputNode, pageModel: MobileContentRendererPageModel, fontService: FontService) {
        
        self.inputNode = inputNode
        self.pageModel = pageModel
        self.fontService = fontService
        
        inputLabel = inputNode.labelNode?.textNode?.text
        placeholder = inputNode.placeholderNode?.textNode?.text
    }
    
    var isHidden: Bool {
        return inputNode.inputType == .hidden
    }
    
    var isRequired: Bool {
        return inputNode.isRequired
    }
    
    func inputChanged(text: String?) {
        inputValue = text
    }
    
    func getInputName() -> String? {
        return inputNode.name
    }
    
    func getInputValue() -> String? {
        
        if inputNode.inputType == .hidden {
            return inputNode.value
        }
        
        return inputValue
    }
}
