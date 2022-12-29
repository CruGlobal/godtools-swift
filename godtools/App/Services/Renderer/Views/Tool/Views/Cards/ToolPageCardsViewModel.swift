//
//  ToolPageCardsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class ToolPageCardsViewModel: MobileContentViewModel {
    
    private let cards: [TractPage.Card]
    private let cardJumpService: CardJumpService
    
    let hidesCardJump: ObservableValue<Bool> = ObservableValue(value: true)
    
    init(cards: [TractPage.Card], renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentAnalytics, cardJumpService: CardJumpService) {
                
        self.cards = cards
        self.cardJumpService = cardJumpService
        
        super.init(baseModels: cards, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
        
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
}

// MARK: - Inputs

extension ToolPageCardsViewModel {
    
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
