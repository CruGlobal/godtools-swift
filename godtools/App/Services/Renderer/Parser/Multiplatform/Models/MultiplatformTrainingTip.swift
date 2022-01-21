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
    
    private let mpTip: Tip
    
    required init(tip: Tip) {
        
        self.mpTip = tip
    }
    
    var id: String {
        return mpTip.id
    }
    
    var tip: TipModelType {
        return MultiplatformTip(tip: mpTip)
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
