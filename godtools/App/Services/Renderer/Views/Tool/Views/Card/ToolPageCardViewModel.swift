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
    private let cardModel: CardModelType
    private let analytics: AnalyticsContainer
    private let fontService: FontService
    private let localizationServices: LocalizationServices
    private let trainingTipsEnabled: Bool
    private let analyticsEventsObjects: [MobileContentAnalyticsEvent]
    private let cardPosition: Int
    private let numberOfCards: Int
     
    let hidesHeaderTrainingTip: Bool
    let hidesCardPositionLabel: Bool
    let hidesPreviousButton: Bool
    let hidesNextButton: Bool
    let isHiddenCard: Bool
    
    required init(cardModel: CardModelType, pageModel: MobileContentRendererPageModel, analytics: AnalyticsContainer, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService, localizationServices: LocalizationServices, trainingTipsEnabled: Bool) {
                        
        self.cardModel = cardModel
        self.pageModel = pageModel
        self.analytics = analytics
        self.fontService = fontService
        self.localizationServices = localizationServices
        self.trainingTipsEnabled = trainingTipsEnabled
        self.cardPosition = cardModel.cardPositionInVisibleCards
        self.numberOfCards = cardModel.numberOfVisibleCards
        self.isHiddenCard = cardModel.isHidden
        
        if isHiddenCard {
            hidesCardPositionLabel = true
            hidesPreviousButton = true
            hidesNextButton = true
        }
        else {
            let isLastCard: Bool = cardPosition >= numberOfCards - 1
            hidesCardPositionLabel = false
            hidesPreviousButton = false
            hidesNextButton = isLastCard ? true : false
        }
        
        analyticsEventsObjects = MobileContentAnalyticsEvent.initAnalyticsEvents(
            analyticsEvents: cardModel.getAnalyticsEvents(),
            mobileContentAnalytics: mobileContentAnalytics,
            page: pageModel
        )
        
        hidesHeaderTrainingTip = !cardModel.hasTrainingTip
    }
    
    var title: String? {
        return cardModel.text
    }
    
    var titleColor: UIColor {
        return cardModel.getTextColor()?.color ?? pageModel.pageColors.primaryColor
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
        return pageModel.language.languageDirection.semanticContentAttribute
    }
    
    var dismissListeners: [String] {
        return cardModel.dismissListeners
    }
    
    var listeners: [String] {
        return cardModel.listeners
    }
    
    func backgroundImageWillAppear() -> MobileContentBackgroundImageViewModel {
        return MobileContentBackgroundImageViewModel(
            backgroundImageNode: cardModel,
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
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: screenName, siteSection: "", siteSubSection: ""))
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
