//
//  TractPageCardViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser
import LocalizationServices

class TractPageCardViewModel: MobileContentViewModel {
    
    private let cardModel: TractPage.Card
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let localizationServices: LocalizationServices
    private let trainingTipsEnabled: Bool
    private let visibleAnalyticsEventsObjects: [MobileContentRendererAnalyticsEvent]
    private let numberOfVisbleCards: Int
     
    let hidesHeaderTrainingTip: Bool
    let hidesCardPositionLabel: Bool
    let hidesPreviousButton: Bool
    let hidesNextButton: Bool
    let isHiddenCard: Bool
    
    init(cardModel: TractPage.Card, renderedPageContext: MobileContentRenderedPageContext, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, mobileContentAnalytics: MobileContentRendererAnalytics, localizationServices: LocalizationServices, numberOfVisbleCards: Int, trainingTipsEnabled: Bool) {
                        
        self.cardModel = cardModel
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
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
        
        visibleAnalyticsEventsObjects = MobileContentRendererAnalyticsEvent.initAnalyticsEvents(
            analyticsEvents: cardModel.getAnalyticsEvents(type: .visible),
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
        
        super.init(baseModel: cardModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private var analyticsScreenName: String {
        
        let resource: ResourceModel = renderedPageContext.resource
        let page: Int32 = renderedPageContext.pageModel.position
        let cardPosition: Int = Int(cardModel.position)
        
        let pageAnalyticsScreenName: String = resource.abbreviation + "-" + String(page)
        
        return pageAnalyticsScreenName + TractPageCardAnalyticsScreenName(cardPosition: cardPosition).screenName
    }
    
    private var analyticsSiteSection: String {
        return renderedPageContext.resource.abbreviation
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
    
    private func getTranslatedStringFromToolLanguageElseAppLanguage(localizedKey: String) -> String {
        
        if let languageTranslation = localizationServices.stringsRepository.stringForLocale(localeIdentifier: renderedPageContext.language.localeId, key: localizedKey) {
            return languageTranslation
        }
        else if let appLanguageTranslation = localizationServices.stringsRepository.stringForLocale(localeIdentifier: renderedPageContext.appLanguage, key: localizedKey) {
            return appLanguageTranslation
        }
        
        return localizationServices.stringForEnglish(key: localizedKey)
    }
    
    var title: String? {
        return cardModel.label?.text
    }
    
    var titleColor: UIColor {
        return cardModel.label?.textColor ?? renderedPageContext.pageModel.primaryColor
    }
    
    var titleFont: UIFont {
        return FontLibrary.systemUIFont(size: 19, weight: .regular)
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
        return FontLibrary.systemUIFont(size: 18, weight: .regular)
    }
    
    var previousButtonTitle: String? {
        
        let prevLocalizedKey: String = LocalizableStringKeys.cardPrevButtonTitle.key
        
        return getTranslatedStringFromToolLanguageElseAppLanguage(localizedKey: prevLocalizedKey)
    }
    
    var previousButtonTitleColor: UIColor {
        return .gray
    }
    
    var previousButtonTitleFont: UIFont {
        return FontLibrary.systemUIFont(size: 18, weight: .regular)
    }
    
    var nextButtonTitle: String? {
        
        let nextLocalizedKey: String = LocalizableStringKeys.cardNextButtonTitle.key
        
        return getTranslatedStringFromToolLanguageElseAppLanguage(localizedKey: nextLocalizedKey)
    }
    
    var nextButtonTitleColor: UIColor {
        return .gray
    }
    
    var nextButtonTitleFont: UIFont {
        return FontLibrary.systemUIFont(size: 18, weight: .regular)
    }
    
    func containsDismissListener(eventId: EventId) -> Bool {
        return cardModel.dismissListeners.contains(eventId)
    }
    
    func containsListener(eventId: EventId) -> Bool {
        return cardModel.listeners.contains(eventId)
    }
}

// MARK: - Inputs

extension TractPageCardViewModel {
    
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
            languageDirection: LanguageDirectionDomainModel(languageModel: renderedPageContext.language)
        )
    }
        
    func cardDidAppear() {
        
        super.viewDidAppear(visibleAnalyticsEvents: visibleAnalyticsEventsObjects)
                       
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            appLanguage: renderedPageContext.appLanguage,
            contentLanguage: renderedPageContext.rendererLanguages.primaryLanguage.localeId,
            contentLanguageSecondary: renderedPageContext.rendererLanguages.parallelLanguage?.localeId
        )
    }
    
    func cardDidDisappear() {
        
        super.viewDidDisappear(visibleAnalyticsEvents: visibleAnalyticsEventsObjects)
    }
}
