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
    
    func getTappedAnalyticsEvents() -> [AnalyticsEventModelType] {
        return multiSelectOption.getAnalyticsEvents(type: .clicked).map({MultiplatformAnalyticsEvent(analyticsEvent: $0)})
    }
    
    func toggleSelected(rendererState: State) {
        
        multiSelectOption.toggleSelected(state: rendererState)
    }
    
    func watchIsSelected(rendererState: State, completion: @escaping ((_ isSelected: Bool) -> Void)) -> FlowWatcher {
        
        let flowWatcher = multiSelectOption.watchIsSelected(state: rendererState) { (boolean: KotlinBoolean) in
            completion(boolean.boolValue)
        }
        
        return flowWatcher
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

        addContentToChildModels(childModels: &childModels, content: multiSelectOption.content)
                
        return childModels
    }
}
