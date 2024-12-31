//
//  TractPageCardsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser
import Combine

class TractPageCardsViewModel: MobileContentViewModel, ObservableObject {
    
    private let cards: [TractPage.Card]
    private let cardJumpService: CardJumpService
        
    @Published private(set) var showsCardJump: Bool = false
    
    init(cards: [TractPage.Card], renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics, cardJumpService: CardJumpService) {
                
        self.cards = cards
        self.cardJumpService = cardJumpService
        
        super.init(baseModels: cards, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
        
        setupBinding()
        
        showsCardJump = !cardJumpService.didShowCardJump
    }
    
    deinit {
        
        cardJumpService.didSaveCardJumpShownSignal.removeObserver(self)
    }
    
    private func setupBinding() {
        
        cardJumpService.didSaveCardJumpShownSignal.addObserver(self) { [weak self] in
            self?.showsCardJump = false
        }
    }
}

// MARK: - Inputs

extension TractPageCardsViewModel {
    
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
