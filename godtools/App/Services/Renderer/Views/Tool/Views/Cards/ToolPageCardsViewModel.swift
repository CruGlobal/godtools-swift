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
    private let renderedPageContext: MobileContentRenderedPageContext
    private let cardJumpService: CardJumpService
    
    let hidesCardJump: ObservableValue<Bool> = ObservableValue(value: true)
    
    required init(cards: [TractPage.Card], renderedPageContext: MobileContentRenderedPageContext, cardJumpService: CardJumpService) {
        
        let visibleCards: [TractPage.Card] = cards.filter({!$0.isHidden})
        
        self.cards = cards
        self.renderedPageContext = renderedPageContext
        self.cardJumpService = cardJumpService
        
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
