//
//  ContentImageModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

protocol ContentImageModelType: MobileContentRenderableModel {
    
    var events: [MultiplatformEventId] { get }
    var resource: String? { get }
    var width: GodToolsToolParser.Dimension { get }
}

extension ContentImageModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
