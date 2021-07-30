//
//  ContentFallbackModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ContentFallbackModelType: MobileContentRenderableModel {
    
}

extension ContentFallbackModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
