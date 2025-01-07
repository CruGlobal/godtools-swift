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
    private let isShowingCardJump: Bool
    
    private var cancellables: Set<AnyCancellable> = Set()
        
    @Published private(set) var showsCardJump: Bool = false
    
    init(cards: [TractPage.Card], renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics, cardJumpService: CardJumpService) {
                
        self.cards = cards
        self.cardJumpService = cardJumpService
        
        let isLiveShareStreaming: Bool = (renderedPageContext.userInfo?[TractViewModel.isLiveShareStreamingKey] as? Bool) ?? false
        
        isShowingCardJump = !cardJumpService.didShowCardJump && !isLiveShareStreaming
        
        super.init(baseModels: cards, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
                
        showsCardJump = isShowingCardJump
        
        if isShowingCardJump {
         
            cardJumpService.didSaveCardJumpPublisher
                .prefix(1)
                .sink { [weak self] _ in
                    self?.showsCardJump = false
                }
                .store(in: &cancellables)
        }
    }
    
    private func saveDidShowCardJump() {
        
        guard isShowingCardJump else {
            return
        }
        
        cardJumpService.saveDidShowCardJump()
    }
}

// MARK: - Inputs

extension TractPageCardsViewModel {
    
    func cardHeaderTapped() {
        saveDidShowCardJump()
    }
    
    func cardSwipedUp() {
        saveDidShowCardJump()
    }
    
    func cardBounceAnimationFinished() {
        saveDidShowCardJump()
    }
}
