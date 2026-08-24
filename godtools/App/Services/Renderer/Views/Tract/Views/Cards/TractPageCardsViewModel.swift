//
//  TractPageCardsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsShared
import Combine

final class TractPageCardsViewModel: MobileContentViewModel, ObservableObject {
    
    private let cards: [TractPage.Card]
    private let cardJumpRepository: CardJumpRepository
    private let isLiveShareStreaming: Bool
    
    private var cancellables: Set<AnyCancellable> = Set()
        
    @Published private(set) var showsCardJump: Bool = false
    
    init(
        cards: [TractPage.Card],
        renderedPageContext: MobileContentRenderedPageContext,
        mobileContentAnalytics: MobileContentRendererAnalytics,
        cardJumpRepository: CardJumpRepository
    ) {
                
        self.cards = cards
        self.cardJumpRepository = cardJumpRepository
        
        isLiveShareStreaming = (renderedPageContext.userInfo?[TractViewModel.isLiveShareStreamingKey] as? Bool) ?? false
                
        super.init(baseModels: cards, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
        
        loadShowsCardJump()
    }
    
    private func loadShowsCardJump() {
        
        let isLiveShareStreaming: Bool = self.isLiveShareStreaming
        
        Task { [weak self] in
            
            let didShowCardJump: Bool = await self?.cardJumpRepository.didShowCardJump ?? false
            
            self?.showsCardJump = !didShowCardJump && !isLiveShareStreaming
        }
    }
    
    private func saveDidShowCardJump() {
        
        showsCardJump = false
        
        let cardJumpRepository: CardJumpRepository = self.cardJumpRepository
        
        Task.detached {
            
            await cardJumpRepository.saveDidShowCardJump()
        }
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
