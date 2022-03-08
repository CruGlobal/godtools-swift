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
    
    private let cardCollectionPage: MultiplatformCardCollectionPage
    private let rendererPageModel: MobileContentRendererPageModel
    private let analytics: AnalyticsContainer
        
    required init(flowDelegate: FlowDelegate, cardCollectionPage: MultiplatformCardCollectionPage, rendererPageModel: MobileContentRendererPageModel, deepLinkService: DeepLinkingServiceType, analytics: AnalyticsContainer) {
        
        self.cardCollectionPage = cardCollectionPage
        self.rendererPageModel = rendererPageModel
        self.analytics = analytics
        
        super.init(flowDelegate: flowDelegate, pageModel: cardCollectionPage, rendererPageModel: rendererPageModel, deepLinkService: deepLinkService, hidesBackgroundImage: false)
    }
    
    required init(flowDelegate: FlowDelegate, pageModel: PageModelType, rendererPageModel: MobileContentRendererPageModel, deepLinkService: DeepLinkingServiceType, hidesBackgroundImage: Bool) {
        fatalError("init(flowDelegate:pageModel:rendererPageModel:deepLinkService:hidesBackgroundImage:) has not been implemented")
    }
    
    private func getPageAnalyticsScreenName() -> String {

        let resource: ResourceModel = rendererPageModel.resource
        let pageId: String = rendererPageModel.pageModel.id
        let separator: String = ":"
        
        let screenName: String = resource.abbreviation + separator + pageId
        
        return screenName
    }
    
    private func getCardAnalyticsScreenName(card: Int) -> String {
        
        let resource: ResourceModel = rendererPageModel.resource
        let pageId: String = rendererPageModel.pageModel.id
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
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: getPageAnalyticsScreenName(), siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection))
    }
    
    func cardDidAppear(card: Int) {
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: getCardAnalyticsScreenName(card: card), siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection))
    }
}
