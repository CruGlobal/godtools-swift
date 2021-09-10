//
//  MultiplatformContentMultiSelectOption.swift
//  godtools
//
//  Created by Levi Eggert on 9/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MultiplatformContentMultiSelectOption: ContentMultiSelectOptionModelType {
    
    private let multiSelectOption: Multiselect.Option
    
    required init(multiSelectOption: Multiselect.Option) {
        
        self.multiSelectOption = multiSelectOption
    }
    
    var backgroundColor: UIColor {
        return multiSelectOption.backgroundColor
    }
    
    var selectedColor: UIColor {
        return multiSelectOption.selectedColor
    }
    
    func toggleSelected(rendererState: MobileContentMultiplatformState) {
        
        multiSelectOption.toggleSelected(state: rendererState.state)
    }
    
    func watchIsSelected(rendererState: MobileContentMultiplatformState, completion: @escaping ((_ isSelected: Bool) -> Void)) -> MultiplatformFlowWatcher {
        
        let flowWatcher = multiSelectOption.watchIsSelected(state: rendererState.state) { (boolean: KotlinBoolean) in
            completion(boolean.boolValue)
        }
        
        return MultiplatformFlowWatcher(flowWatcher: flowWatcher)
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformContentMultiSelectOption {
    
    var restrictTo: String? {
        return nil
    }
    
    var version: String? {
        return nil
    }
    
    var modelContentIsRenderable: Bool {
        return true
    }
    
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
       
        var childModels: [MobileContentRenderableModel] = Array()
        
        var contentText: Text?
        
        for content in multiSelectOption.content {
            if let text = content as? Text, contentText == nil {
                contentText = text
            }
        }
        
        if let contentText = contentText {
            childModels.append(MultiplatformContentText(text: contentText))
        }
        
        return childModels
    }
}
