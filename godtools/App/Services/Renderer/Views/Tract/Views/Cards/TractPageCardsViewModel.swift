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
    private let cardJumpService: CardJumpService
    private let isLiveShareStreaming: Bool
    
    private var cancellables: Set<AnyCancellable> = Set()
        
    @Published private(set) var showsCardJump: Bool = false
    
    init(
        cards: [TractPage.Card],
        renderedPageContext: MobileContentRenderedPageContext,
        mobileContentAnalytics: MobileContentRendererAnalytics,
        cardJumpService: CardJumpService
    ) {
                
        self.cards = cards
        self.cardJumpService = cardJumpService
        
        isLiveShareStreaming = (renderedPageContext.userInfo?[TractViewModel.isLiveShareStreamingKey] as? Bool) ?? false
                
        super.init(baseModels: cards, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
        
        Task {
            
            let didShowCardJump: Bool = await cardJumpService.didShowCardJump
            
            showsCardJump = !didShowCardJump && !isLiveShareStreaming
        }
    }
    
    private func saveDidShowCardJump() {
        
        showsCardJump = false
        
        let cardJumpService: CardJumpService = self.cardJumpService
        
        Task.detached {
            
            await cardJumpService.saveDidShowCardJump()
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
