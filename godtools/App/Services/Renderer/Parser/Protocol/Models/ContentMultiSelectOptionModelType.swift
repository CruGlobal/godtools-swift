//
//  ContentMultiSelectOptionModelType.swift
//  godtools
//
//  Created by Levi Eggert on 9/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ContentMultiSelectOptionModelType: MobileContentRenderableModel {
    
}

extension ContentMultiSelectOptionModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
