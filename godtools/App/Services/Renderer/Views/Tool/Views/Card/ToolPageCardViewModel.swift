//
//  ToolPageCardViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class ToolPageCardViewModel: ToolPageCardViewModelType {
    
    private let renderedPageContext: MobileContentRenderedPageContext
    private let cardModel: TractPage.Card
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
    
    required init(cardModel: TractPage.Card, renderedPageContext: MobileContentRenderedPageContext, analytics: AnalyticsContainer, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService, localizationServices: LocalizationServices, numberOfCards: Int, trainingTipsEnabled: Bool) {
                        
        self.cardModel = cardModel
        self.renderedPageContext = renderedPageContext
        self.analytics = analytics
        self.fontService = fontService
        self.localizationServices = localizationServices
        self.trainingTipsEnabled = trainingTipsEnabled
        self.cardPosition = cardModel.visiblePosition?.intValue ?? 0
        self.numberOfCards = numberOfCards
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
            analyticsEvents: cardModel.analyticsEvents,
            mobileContentAnalytics: mobileContentAnalytics,
            renderedPageContext: renderedPageContext
        )
        
        if !trainingTipsEnabled {
            hidesHeaderTrainingTip = true
        }
        else {
            let hasTrainingTip: Bool = cardModel.tips.count > 0
            hidesHeaderTrainingTip = !hasTrainingTip
        }
    }
    
    var title: String? {
        return cardModel.label?.text
    }
    
    var titleColor: UIColor {
        return cardModel.label?.textColor ?? renderedPageContext.pageModel.primaryColor
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
        return localizationServices.stringForLanguage(language: renderedPageContext.language, key: "card_status1")
    }
    
    var previousButtonTitleColor: UIColor {
        return .gray
    }
    
    var previousButtonTitleFont: UIFont {
        return fontService.getFont(size: 18, weight: .regular)
    }
    
    var nextButtonTitle: String? {
        return localizationServices.stringForLanguage(language: renderedPageContext.language, key: "card_status2")
    }
    
    var nextButtonTitleColor: UIColor {
        return .gray
    }
    
    var nextButtonTitleFont: UIFont {
        return fontService.getFont(size: 18, weight: .regular)
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        return renderedPageContext.language.languageDirection.semanticContentAttribute
    }
    
    var dismissListeners: [EventId] {
        return Array(cardModel.dismissListeners)
    }
    
    var listeners: [EventId] {
        return Array(cardModel.listeners)
    }
    
    func backgroundImageWillAppear() -> MobileContentBackgroundImageViewModel? {
        
        guard let backgroundImageFileName = cardModel.backgroundImage?.name else {
            return nil
        }
        
        let backgroundImageModel = BackgroundImageModel(
            backgroundImageFileName: backgroundImageFileName,
            backgroundImageAlignment: cardModel.backgroundImageGravity,
            backgroundImageScale: cardModel.backgroundImageScaleType
        )
        
        return MobileContentBackgroundImageViewModel(
            backgroundImageModel: backgroundImageModel,
            manifestResourcesCache: renderedPageContext.resourcesCache,
            languageDirection: renderedPageContext.language.languageDirection
        )
    }
        
    func cardDidAppear() {
        mobileContentDidAppear()
        
        let resource: ResourceModel = renderedPageContext.resource
        let page: Int = renderedPageContext.page
        
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
        return renderedPageContext.language
    }
    
    var analyticsEvents: [MobileContentAnalyticsEvent] {
        return analyticsEventsObjects
    }
}
