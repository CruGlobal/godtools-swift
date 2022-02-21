//
//  MultiplatformNumber.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformNumber {
    
    private let contentText: Text
    
    required init(text: Text) {
        
        self.contentText = text
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformNumber: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
        
        var childModels: [MobileContentRenderableModel] = Array()
                
        childModels.append(MultiplatformContentText(text: contentText))
        
        return childModels
    }
}
