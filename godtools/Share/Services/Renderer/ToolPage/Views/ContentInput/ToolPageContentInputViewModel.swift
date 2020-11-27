//
//  ToolPageContentInputViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageContentInputViewModel: ToolPageContentInputViewModelType {
    
    private let fontService: FontService
    private let toolPageColors: ToolPageColors
    private let defaultTextNodeTextColor: UIColor?
    
    private(set) var inputValue: String?
    
    let inputNode: ContentInputNode
    let inputLabel: String?
    let placeholder: String?
    
    required init(inputNode: ContentInputNode, fontService: FontService, toolPageColors: ToolPageColors, defaultTextNodeTextColor: UIColor?) {
        
        self.inputNode = inputNode
        self.fontService = fontService
        self.toolPageColors = toolPageColors
        self.defaultTextNodeTextColor = defaultTextNodeTextColor
        
        inputLabel = inputNode.labelNode?.textNode?.text
        placeholder = inputNode.placeholderNode?.textNode?.text
    }
    
    func inputChanged(text: String?) {
        inputValue = text
    }
}
