//
//  MultiplatformContentMultiSelect.swift
//  godtools
//
//  Created by Levi Eggert on 9/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentMultiSelect: ContentMultiSelectModelType {
    
    private let multiSelect: Multiselect
    
    required init(multiSelect: Multiselect) {
        
        self.multiSelect = multiSelect
    }
    
    var numberOfColumns: Int32 {
        return multiSelect.columns
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformContentMultiSelect {
    
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
                
        childModels.append(contentsOf: multiSelect.options)
        
        return childModels
    }
}
