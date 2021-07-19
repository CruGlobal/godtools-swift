//
//  TitleModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol TitleModelType: MobileContentRenderableModel {
        
    func getTextColor() -> MobileContentColor?
}

extension TitleModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
