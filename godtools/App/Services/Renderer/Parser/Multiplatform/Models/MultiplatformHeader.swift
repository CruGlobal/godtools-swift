//
//  MultiplatformHeader.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformHeader: HeaderModelType {
    
    private let header: Header
    
    let trainingTipId: String?
    let trainingTip: Tip?
    
    required init(header: Header) {
        
        self.header = header
        
        self.trainingTipId = header.tip?.id
        
        if let tip = header.tip {
            self.trainingTip = tip
        }
        else {
            self.trainingTip = nil
        }
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformHeader {
    
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
         
        if let number = header.number {
            childModels.append(MultiplatformNumber(text: number))
        }
        
        if let title = header.title {
            childModels.append(MultiplatformTitle(text: title))
        }
        
        if let trainingTip = self.trainingTip {
            childModels.append(trainingTip)
        }
        
        return childModels
    }
}
