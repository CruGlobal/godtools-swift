//
//  ToolPageCardsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ToolPageCardsViewModel: NSObject, ToolPageCardsViewModelType {
    
    private let cardsNode: CardsNode
    private let pageModel: MobileContentRendererPageModel
    private let cardJumpService: CardJumpService
    
    let hidesCardJump: ObservableValue<Bool> = ObservableValue(value: true)
    let numberOfCards: Int
    let numberOfVisibleCards: Int
    
    required init(cardsNode: CardsNode, pageModel: MobileContentRendererPageModel, cardJumpService: CardJumpService) {
        
        self.cardsNode = cardsNode
        self.pageModel = pageModel
        self.cardJumpService = cardJumpService
        self.numberOfCards = cardsNode.cards.count
        self.numberOfVisibleCards = cardsNode.visibleCards.count
        
        super.init()
        
        setupBinding()
        
        hidesCardJump.accept(value: cardJumpService.didShowCardJump)
    }
    
    deinit {
        
        cardJumpService.didSaveCardJumpShownSignal.removeObserver(self)
    }
    
    private func setupBinding() {
        
        cardJumpService.didSaveCardJumpShownSignal.addObserver(self) { [weak self] in
            self?.hidesCardJump.accept(value: true)
        }
    }
    
    func cardHeaderTapped() {
        cardJumpService.saveDidShowCardJump()
    }
    
    func cardSwipedUp() {
        cardJumpService.saveDidShowCardJump()
    }
    
    func cardBounceAnimationFinished() {
        cardJumpService.saveDidShowCardJump()
    }
}
