//
//  ModalsModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ModalsModelType: MobileContentRenderableModel {
    
}

extension ModalsModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
