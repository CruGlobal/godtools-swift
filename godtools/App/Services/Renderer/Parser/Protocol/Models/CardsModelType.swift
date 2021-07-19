//
//  CardsModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol CardsModelType: MobileContentRenderableModel {
    
    var numberOfCards: Int { get }
    var numberOfVisibleCards: Int { get }
}

extension CardsModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
