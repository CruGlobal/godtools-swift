//
//  TrainingTipModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol TrainingTipModelType: MobileContentRenderableModel {
    
    var id: String? { get }
    var tip: TipModelType? { get }
}

extension TrainingTipModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
