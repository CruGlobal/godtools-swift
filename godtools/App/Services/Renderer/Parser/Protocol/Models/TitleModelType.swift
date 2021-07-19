//
//  TitleModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol TitleModelType: MobileContentRenderableModel {
    
    func getTextColor() -> MobileContentRGBAColor?
}

extension TitleModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
