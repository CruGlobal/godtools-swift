//
//  ToolPageCardsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ToolPageCardsViewModel: ToolPageCardsViewModelType {
    
    private let cardsNode: CardsNode
    
    let currentCard: ObservableValue<AnimatableValue<Int?>> = ObservableValue(value: AnimatableValue(value: nil, animated: false))
    let numberOfCards: Int
    let numberOfVisibleCards: Int
    
    required init(cardsNode: CardsNode) {
        
        self.cardsNode = cardsNode
        self.numberOfCards = cardsNode.cards.count
        self.numberOfVisibleCards = cardsNode.visibleCards.count
    }
}
