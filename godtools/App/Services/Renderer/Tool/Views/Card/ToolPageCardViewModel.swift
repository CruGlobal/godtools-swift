//
//  ToolPageCardViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageCardViewModel: ToolPageCardViewModelType {
    
    private let pageModel: MobileContentRendererPageModel
    private let cardNode: CardNode
    private let cardsNode: CardsNode
    private let analytics: AnalyticsContainer
    private let fontService: FontService
    private let localizationServices: LocalizationServices
    private let trainingTipsEnabled: Bool
    private let analyticsEventsObjects: [MobileContentAnalyticsEvent]
    private let cardPosition: Int
    private let numberOfCards: Int
     
    let hidesHeaderTrainingTip: ObservableValue<Bool> = ObservableValue(value: true)
    let hidesCardPositionLabel: Bool
    let hidesPreviousButton: Bool
    let hidesNextButton: Bool
    let isHiddenCard: Bool
    
    required init(cardNode: CardNode, cardsNode: CardsNode, pageModel: MobileContentRendererPageModel, analytics: AnalyticsContainer, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService, localizationServices: LocalizationServices, trainingTipsEnabled: Bool) {
                
        let visibleCards: [CardNode] = cardsNode.visibleCards
        
        self.cardNode = cardNode
        self.cardsNode = cardsNode
        self.pageModel = pageModel
        self.analytics = analytics
        self.fontService = fontService
        self.localizationServices = localizationServices
        self.trainingTipsEnabled = trainingTipsEnabled
        self.cardPosition = visibleCards.firstIndex(of: cardNode) ?? 0
        self.numberOfCards = visibleCards.count
        self.isHiddenCard = cardNode.isHidden
        
        if isHiddenCard {
            hidesCardPositionLabel = true
            hidesPreviousButton = true
            hidesNextButton = true
        }
        else {
            let isLastCard: Bool = cardPosition >= numberOfCards - 1
            hidesCardPositionLabel = false
            hidesPreviousButton = false
            hidesNextButton = (pageModel.isLastPage || isLastCard) ? true : false
        }
        
        if let analyticsEventsNode = cardNode.analyticsEventsNode {
            analyticsEventsObjects = MobileContentAnalyticsEvent.initEvents(eventsNode: analyticsEventsNode, mobileContentAnalytics: mobileContentAnalytics)
        }
        else {
            analyticsEventsObjects = []
        }
                        
        checkIfHeaderTrainingTipShouldBeEnabled()
    }
    
    private func checkIfHeaderTrainingTipShouldBeEnabled() {
        
        guard trainingTipsEnabled else {
            return
        }
        
        let cardNode: MobileContentXmlNode = self.cardNode
        
        DispatchQueue.global().async { [weak self] in
            let trainingTipNode: TrainingTipNode? = self?.recurseForTrainingTipNode(nodes: [cardNode])
            DispatchQueue.main.async { [weak self] in
                if trainingTipNode != nil {
                    self?.hidesHeaderTrainingTip.accept(value: false)
                }
            }
        }
    }
    
    private func recurseForTrainingTipNode(nodes: [MobileContentXmlNode]) -> TrainingTipNode? {
        
        for node in nodes {
            
            if let trainingTipNode = node as? TrainingTipNode {
                return trainingTipNode
            }
            
            if let trainingTipNode: TrainingTipNode = recurseForTrainingTipNode(nodes: node.children) {
                return trainingTipNode
            }
        }
        
        return nil
    }
    
    var title: String? {
        let title: String? = cardNode.labelNode?.textNode?.text
        return title
    }
    
    var titleColor: UIColor {
        return cardNode.labelNode?.textNode?.getTextColor()?.color ?? pageModel.pageColors.primaryColor
    }
    
    var titleFont: UIFont {
        return fontService.getFont(size: 19, weight: .regular)
    }
    
    var titleAlignment: NSTextAlignment {
        return languageTextAlignment
    }
    
    var cardPositionLabel: String? {
        return String(cardPosition+1) + "/" + String(numberOfCards)
    }
    
    var cardPositionLabelTextColor: UIColor {
        return .gray
    }
    
    var cardPositionLabelFont: UIFont {
        return fontService.getFont(size: 18, weight: .regular)
    }
    
    var previousButtonTitle: String? {
        return localizationServices.stringForLanguage(language: pageModel.language, key: "card_status1")
    }
    
    var previousButtonTitleColor: UIColor {
        return .gray
    }
    
    var previousButtonTitleFont: UIFont {
        return fontService.getFont(size: 18, weight: .regular)
    }
    
    var nextButtonTitle: String? {
        return localizationServices.stringForLanguage(language: pageModel.language, key: "card_status2")
    }
    
    var nextButtonTitleColor: UIColor {
        return .gray
    }
    
    var nextButtonTitleFont: UIFont {
        return fontService.getFont(size: 18, weight: .regular)
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        return pageModel.languageDirectionSemanticContentAttribute
    }
    
    var dismissListeners: [String] {
        return cardNode.dismissListeners
    }
    
    var listeners: [String] {
        return cardNode.listeners
    }
    
    func backgroundImageWillAppear() -> MobileContentBackgroundImageViewModel {
        return MobileContentBackgroundImageViewModel(
            backgroundImageNode: cardNode,
            manifestResourcesCache: pageModel.resourcesCache,
            languageDirection: pageModel.language.languageDirection
        )
    }
        
    func cardDidAppear() {
        mobileContentDidAppear()
        
        let resource: ResourceModel = pageModel.resource
        let page: Int = pageModel.page
        
        let pageAnalyticsScreenName: String = resource.abbreviation + "-" + String(page)
        let screenName: String = pageAnalyticsScreenName + ToolPageCardAnalyticsScreenName(cardPosition: cardPosition).screenName
        analytics.pageViewedAnalytics.trackPageView(screenName: screenName, siteSection: "", siteSubSection: "")
    }
    
    func cardDidDisappear() {
        mobileContentDidDisappear()
    }
}

// MARK: - MobileContentViewModelType

extension ToolPageCardViewModel: MobileContentViewModelType {
    
    var language: LanguageModel {
        return pageModel.language
    }
    
    var analyticsEvents: [MobileContentAnalyticsEvent] {
        return analyticsEventsObjects
    }
    
    var defaultAnalyticsEventsTrigger: AnalyticsEventNodeTrigger {
        return .visible
    }
}
