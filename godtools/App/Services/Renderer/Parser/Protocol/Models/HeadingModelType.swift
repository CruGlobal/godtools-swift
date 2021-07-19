//
//  HeadingModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol HeadingModelType: MobileContentRenderableModel {
    
    func getTextColor() -> MobileContentRGBAColor?
}

extension HeadingModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
