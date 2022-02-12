//
//  HeaderModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

protocol HeaderModelType: MobileContentRenderableModel {
    
    var trainingTipId: String? { get }
    var trainingTip: Tip? { get }
}

extension HeaderModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
