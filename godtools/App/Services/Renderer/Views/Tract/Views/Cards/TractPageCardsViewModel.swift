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
    
    private var cancellables: Set<AnyCancellable> = Set()
        
    @Published private(set) var showsCardJump: Bool = false
    
    init(cards: [TractPage.Card], renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics, cardJumpService: CardJumpService) {
                
        self.cards = cards
        self.cardJumpService = cardJumpService
        
        super.init(baseModels: cards, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
                
        //showsCardJump = !cardJumpService.didShowCardJump
        showsCardJump = true
        
        if showsCardJump {
         
            cardJumpService.didSaveCardJumpPublisher
                .prefix(1)
                .sink { [weak self] _ in
                    self?.showsCardJump = false
                }
                .store(in: &cancellables)
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
