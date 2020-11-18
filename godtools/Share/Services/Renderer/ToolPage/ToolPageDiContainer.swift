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
    let language: LanguageModel
    let translationsFileCache: TranslationsFileCache
    let mobileContentNodeParser: MobileContentXmlNodeParser
    let mobileContentAnalytics: MobileContentAnalytics
    let mobileContentEvents: MobileContentEvents
    let fontService: FontService
    let followUpsService: FollowUpsService
    let localizationServices: LocalizationServices
    
    required init(manifest: MobileContentXmlManifest, language: LanguageModel, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, mobileContentAnalytics: MobileContentAnalytics, mobileContentEvents: MobileContentEvents, fontService: FontService, followUpsService: FollowUpsService, localizationServices: LocalizationServices) {
        
        self.manifest = manifest
        self.language = language
        self.translationsFileCache = translationsFileCache
        self.mobileContentNodeParser = mobileContentNodeParser
        self.mobileContentAnalytics = mobileContentAnalytics
        self.mobileContentEvents = mobileContentEvents
        self.fontService = fontService
        self.followUpsService = followUpsService
        self.localizationServices = localizationServices
    }
}
