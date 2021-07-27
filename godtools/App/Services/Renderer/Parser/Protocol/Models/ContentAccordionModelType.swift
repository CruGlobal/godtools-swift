//
//  ContentAccordionModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ContentAccordionModelType: MobileContentRenderableModel {
    
}

extension ContentAccordionModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
