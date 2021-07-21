//
//  ContentSpacerModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ContentSpacerModelType: MobileContentRenderableModel {
    
    var height: Int32 { get }
    var mode: MobileContentSpacerMode { get }
}

extension ContentSpacerModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
