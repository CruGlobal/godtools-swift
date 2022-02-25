//
//  ToolPageCardsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class ToolPageCardsViewModel: NSObject, ToolPageCardsViewModelType {
    
    private let cards: [TractPage.Card]
    private let rendererPageModel: MobileContentRendererPageModel
    private let cardJumpService: CardJumpService
    
    let hidesCardJump: ObservableValue<Bool> = ObservableValue(value: true)
    let numberOfCards: Int
    let numberOfVisibleCards: Int
    
    required init(cards: [TractPage.Card], rendererPageModel: MobileContentRendererPageModel, cardJumpService: CardJumpService) {
        
        let visibleCards: [TractPage.Card] = cards.filter({!$0.isHidden})
        
        self.cards = cards
        self.rendererPageModel = rendererPageModel
        self.cardJumpService = cardJumpService
        self.numberOfCards = cards.count
        self.numberOfVisibleCards = visibleCards.count
        
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
