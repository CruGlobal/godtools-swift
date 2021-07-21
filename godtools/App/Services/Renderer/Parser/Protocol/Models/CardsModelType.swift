//
//  CardsModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol CardsModelType: MobileContentRenderableModel {
    
    var cards: [CardModelType] { get }
    var visibleCards: [CardModelType] { get }
    var numberOfCards: Int { get }
    var numberOfVisibleCards: Int { get }
}

extension CardsModelType {
    
    var visibleCards: [CardModelType] {
        return cards.filter({!$0.isHidden})
    }
    
    var numberOfCards: Int {
        return cards.count
    }
    
    var numberOfVisibleCards: Int {
        return visibleCards.count
    }
}

extension CardsModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
