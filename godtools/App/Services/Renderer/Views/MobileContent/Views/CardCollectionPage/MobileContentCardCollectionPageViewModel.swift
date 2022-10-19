//
//  MobileContentCardCollectionPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentCardCollectionPageViewModel: MobileContentPageViewModel, MobileContentCardCollectionPageViewModelType {
    
    private let cardCollectionPage: CardCollectionPage
    private let renderedPageContext: MobileContentRenderedPageContext
    private let analytics: AnalyticsContainer
        
    init(cardCollectionPage: CardCollectionPage, renderedPageContext: MobileContentRenderedPageContext, analytics: AnalyticsContainer) {
        
        self.cardCollectionPage = cardCollectionPage
        self.renderedPageContext = renderedPageContext
        self.analytics = analytics
        
        super.init(pageModel: cardCollectionPage, renderedPageContext: renderedPageContext, hidesBackgroundImage: false)
    }
    
    required init(pageModel: Page, renderedPageContext: MobileContentRenderedPageContext, hidesBackgroundImage: Bool) {
        fatalError("init(pageModel:renderedPageContext:hidesBackgroundImage:) has not been implemented")
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
    
    func pageDidAppear() {
        
        let trackScreen = TrackScreenModel(
            screenName: getPageAnalyticsScreenName(),
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: renderedPageContext.language.code,
            secondaryContentLanguage: nil
        )
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreen)
    }
    
    func cardDidAppear(card: Int) {
        
        let trackScreen = TrackScreenModel(
            screenName: getCardAnalyticsScreenName(card: card),
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: renderedPageContext.language.code,
            secondaryContentLanguage: nil
        )
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreen)
    }
}
