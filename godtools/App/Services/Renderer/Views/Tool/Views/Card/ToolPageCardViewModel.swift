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
    private let numberOfVisbleCards: Int
     
    let hidesHeaderTrainingTip: Bool
    let hidesCardPositionLabel: Bool
    let hidesPreviousButton: Bool
    let hidesNextButton: Bool
    let isHiddenCard: Bool
    
    required init(cardModel: TractPage.Card, renderedPageContext: MobileContentRenderedPageContext, analytics: AnalyticsContainer, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService, localizationServices: LocalizationServices, numberOfVisbleCards: Int, trainingTipsEnabled: Bool) {
                        
        self.cardModel = cardModel
        self.renderedPageContext = renderedPageContext
        self.analytics = analytics
        self.fontService = fontService
        self.localizationServices = localizationServices
        self.trainingTipsEnabled = trainingTipsEnabled
        self.numberOfVisbleCards = numberOfVisbleCards
        self.isHiddenCard = cardModel.isHidden
        
        if let visiblePosition = cardModel.visiblePosition?.intValue {
            
            let isLastCard: Bool = visiblePosition >= numberOfVisbleCards - 1
            hidesCardPositionLabel = false
            hidesPreviousButton = false
            hidesNextButton = isLastCard ? true : false
        } else {
            
            hidesCardPositionLabel = true
            hidesPreviousButton = true
            hidesNextButton = true
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
    
    private var analyticsScreenName: String {
        
        let resource: ResourceModel = renderedPageContext.resource
        let page: Int = renderedPageContext.page
        let cardPosition: Int = Int(cardModel.position)
        
        let pageAnalyticsScreenName: String = resource.abbreviation + "-" + String(page)
        
        return pageAnalyticsScreenName + ToolPageCardAnalyticsScreenName(cardPosition: cardPosition).screenName
    }
    
    private var analyticsSiteSection: String {
        return renderedPageContext.resource.abbreviation
    }
    
    private var analyticsSiteSubSection: String {
        return ""
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
        
        guard let visiblePosition = cardModel.visiblePosition?.intValue else {
            return nil
        }
        
        return String(visiblePosition + 1) + "/" + String(numberOfVisbleCards)
    }
    
    var cardPositionLabelTextColor: UIColor {
        return .gray
    }
    
    var cardPositionLabelFont: UIFont {
        return fontService.getFont(size: 18, weight: .regular)
    }
    
    var previousButtonTitle: String? {
        return localizationServices.stringForLocaleElseSystem(localeIdentifier: renderedPageContext.language.code, key: "card_status1")
    }
    
    var previousButtonTitleColor: UIColor {
        return .gray
    }
    
    var previousButtonTitleFont: UIFont {
        return fontService.getFont(size: 18, weight: .regular)
    }
    
    var nextButtonTitle: String? {
        return localizationServices.stringForLocaleElseSystem(localeIdentifier: renderedPageContext.language.code, key: "card_status2")
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
    
    func backgroundImageWillAppear() -> MobileContentBackgroundImageViewModel? {
        
        guard let backgroundImageResource = cardModel.backgroundImage else {
            return nil
        }
        
        let backgroundImageModel = BackgroundImageModel(
            backgroundImageResource: backgroundImageResource,
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
                   
        let trackScreen =  TrackScreenModel(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: renderedPageContext.language.code,
            secondaryContentLanguage: nil
        )
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreen)
    }
    
    func cardDidDisappear() {
        mobileContentDidDisappear()
    }
    
    func containsDismissListener(eventId: EventId) -> Bool {
        return cardModel.dismissListeners.contains(eventId)
    }
    
    func containsListener(eventId: EventId) -> Bool {
        return cardModel.listeners.contains(eventId)
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
