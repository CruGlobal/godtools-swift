//
//  TitleModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol TitleModelType: MobileContentRenderableModel {
        
    func getTextColor() -> UIColor
}

extension TitleModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
