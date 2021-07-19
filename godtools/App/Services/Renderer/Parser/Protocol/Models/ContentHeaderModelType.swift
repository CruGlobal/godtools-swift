//
//  ContentHeaderModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ContentHeaderModelType: MobileContentRenderableModel {
    
}

extension ContentHeaderModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
