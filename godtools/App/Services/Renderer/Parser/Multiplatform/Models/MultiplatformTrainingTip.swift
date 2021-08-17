//
//  MultiplatformTrainingTip.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformTrainingTip: TrainingTipModelType {
    
    private let tip: Tip
    
    required init(tip: Tip) {
        
        self.tip = tip
    }
    
    var id: String? {
        return tip.id
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformTrainingTip {
    
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
        return Array()
    }
}
