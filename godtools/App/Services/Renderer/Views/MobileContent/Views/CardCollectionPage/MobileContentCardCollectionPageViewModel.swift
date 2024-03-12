//
//  MobileContentCardCollectionPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentCardCollectionPageViewModel: MobileContentPageViewModel {
    
    private let cardCollectionPage: CardCollectionPage
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    
    let numberOfCards: Int
        
    init(cardCollectionPage: CardCollectionPage, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase) {
        
        self.cardCollectionPage = cardCollectionPage
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.numberOfCards = cardCollectionPage.cards.count
        
        super.init(pageModel: cardCollectionPage, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics, hidesBackgroundImage: false)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    var layoutDirection: ApplicationLayoutDirection {
        return renderedPageContext.primaryLanguageLayoutDirection
    }
    
    private func getPageAnalyticsScreenName() -> String {
        
        let resource: ResourceModel = renderedPageContext.resource
        let pageId: String = renderedPageContext.pageModel.id
        let separator: String = ":"
        
        let screenName: String = resource.abbreviation + separator + pageId
        
        return screenName
    }
    
    private func getCardAnalyticsScreenName(card: Int) -> String {
        
        let resource: ResourceModel = renderedPageContext.resource
        let pageId: String = renderedPageContext.pageModel.id
        let cardId: String = getCardId(card: card)
        let separator: String = ":"
        
        let screenName: String = resource.abbreviation + separator + pageId + separator + cardId
        
        return screenName
    }
    
    func getCardId(card: Int) -> String {
        
        let cards: [CardCollectionPage.Card] = cardCollectionPage.cards
        let cardId: String
        
        if card >= 0 && card < cards.count {
            cardId = cards[card].id
        }
        else {
            assertionFailure("Failed to get card at index: \(card)")
            cardId = ""
        }
        
        return cardId
    }
    
    func getCardPosition(cardId: String) -> Int? {
        
        let cards: [CardCollectionPage.Card] = cardCollectionPage.cards
        
        for index in 0 ..< cards.count {
            let card: CardCollectionPage.Card = cards[index]
            if card.id == cardId {
                return index
            }
        }
        
        return nil
    }
}

// MARK: - Inputs

extension MobileContentCardCollectionPageViewModel {
    
    func pageDidAppear() {
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: getPageAnalyticsScreenName(),
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: renderedPageContext.language.localeIdentifier,
            contentLanguageSecondary: nil
        )
    }
    
    func cardWillAppear(card: Int) -> MobileContentView? {
        
        let view: MobileContentView? = renderedPageContext.viewRenderer.recurseAndRender(
            renderableModel: cardCollectionPage.cards[card],
            renderableModelParent: nil,
            renderedPageContext: renderedPageContext
        )
                
        return view
    }
    
    func cardDidAppear(card: Int) {
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: getCardAnalyticsScreenName(card: card),
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: renderedPageContext.language.localeIdentifier,
            contentLanguageSecondary: nil
        )        
    }
}
