//
//  ToolPageDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 11/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ToolPageDiContainer {
    
    let manifest: MobileContentXmlManifest
    let manifestResourcesCache: ManifestResourcesCache
    let language: LanguageModel
    let translationsFileCache: TranslationsFileCache
    let mobileContentNodeParser: MobileContentXmlNodeParser
    let mobileContentAnalytics: MobileContentAnalytics
    let mobileContentEvents: MobileContentEvents
    let analytics: AnalyticsContainer
    let fontService: FontService
    let followUpsService: FollowUpsService
    let localizationServices: LocalizationServices
    let cardJumpService: CardJumpService
    let trainingTipsEnabled: Bool
    
    required init(manifest: MobileContentXmlManifest, language: LanguageModel, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, mobileContentAnalytics: MobileContentAnalytics, mobileContentEvents: MobileContentEvents, analytics: AnalyticsContainer, fontService: FontService, followUpsService: FollowUpsService, localizationServices: LocalizationServices, cardJumpService: CardJumpService, trainingTipsEnabled: Bool) {
        
        self.manifest = manifest
        self.manifestResourcesCache = ManifestResourcesCache(manifest: manifest, translationsFileCache: translationsFileCache)
        self.language = language
        self.translationsFileCache = translationsFileCache
        self.mobileContentNodeParser = mobileContentNodeParser
        self.mobileContentAnalytics = mobileContentAnalytics
        self.mobileContentEvents = mobileContentEvents
        self.analytics = analytics
        self.fontService = fontService
        self.followUpsService = followUpsService
        self.localizationServices = localizationServices
        self.cardJumpService = cardJumpService
        self.trainingTipsEnabled = trainingTipsEnabled
    }
}
