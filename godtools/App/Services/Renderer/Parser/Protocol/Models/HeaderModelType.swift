//
//  HeaderModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol HeaderModelType: MobileContentRenderableModel {
    
    var trainingTip: String? { get }
}

extension HeaderModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
