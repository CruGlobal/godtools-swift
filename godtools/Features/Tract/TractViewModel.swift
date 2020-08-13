//
//  TractViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TractViewModel: NSObject, TractViewModelType {
    
    typealias PageNumber = Int
    
    private let resource: ResourceModel
    private let primaryLanguage: LanguageModel
    private let parallelLanguage: LanguageModel?
    private let translateLanguageNameViewModel: TranslateLanguageNameViewModel
    private let tractManager: TractManager // TODO: Eventually would like to remove this class. ~Levi
    private let tractRemoteShareSubscriber: TractRemoteShareSubscriber
    private let followUpsService: FollowUpsService
    private let viewsService: ViewsService
    private let analytics: AnalyticsContainer
    private let toolOpenedAnalytics: ToolOpenedAnalytics
    private let primaryTractXmlResource: TractXmlResource
    private let parallelTractXmlResource: TractXmlResource?
    
    private var cachedPrimaryTractPages: [PageNumber: TractPage] = Dictionary()
    private var cachedParallelTractPages: [PageNumber: TractPage] = Dictionary()
    private var cachedTractRemoteShareNavigationEvents: [PageNumber: TractRemoteShareNavigationEvent] = Dictionary()
    private var tractPage: Int = 0
        
    let navTitle: ObservableValue<String> = ObservableValue(value: "God Tools")
    let navBarAttributes: TractNavBarAttributes
    let hidesChooseLanguageControl: Bool
    let chooseLanguageControlPrimaryLanguageTitle: String
    let chooseLanguageControlParallelLanguageTitle: String
    let selectedTractLanguage: ObservableValue<TractLanguage>
    let tractXmlPageItems: ObservableValue<[TractXmlPageItem]> = ObservableValue(value: [])
    let currentTractPage: ObservableValue<AnimatableValue<Int>> = ObservableValue(value: AnimatableValue(value: 0, animated: false))
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, primaryLanguage: LanguageModel, primaryTranslationManifest: TranslationManifestData, parallelLanguage: LanguageModel?, parallelTranslationManifest: TranslationManifestData?, languageSettingsService: LanguageSettingsService, tractManager: TractManager, tractRemoteShareSubscriber: TractRemoteShareSubscriber, followUpsService: FollowUpsService, viewsService: ViewsService, localizationServices: LocalizationServices, analytics: AnalyticsContainer, toolOpenedAnalytics: ToolOpenedAnalytics, liveShareStream: String?, tractPage: Int?) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.primaryLanguage = primaryLanguage
        self.parallelLanguage = parallelLanguage?.code != primaryLanguage.code ? parallelLanguage : nil
        self.translateLanguageNameViewModel = TranslateLanguageNameViewModel(localizationServices: localizationServices)
        self.tractManager = tractManager
        self.tractRemoteShareSubscriber = tractRemoteShareSubscriber
        self.followUpsService = followUpsService
        self.viewsService = viewsService
        self.analytics = analytics
        self.toolOpenedAnalytics = toolOpenedAnalytics
        
        primaryTractXmlResource = tractManager.loadResource(translationManifest: primaryTranslationManifest)
        
        if let parallelTranslationManifest = parallelTranslationManifest {
            parallelTractXmlResource = tractManager.loadResource(translationManifest: parallelTranslationManifest)
        }
        else {
            parallelTractXmlResource = nil
        }
        
        let primaryManifest: ManifestProperties = primaryTractXmlResource.manifestProperties
        navBarAttributes = TractNavBarAttributes(
            navBarColor: primaryManifest.navbarColor ?? primaryManifest.primaryColor,
            navBarControlColor: primaryManifest.navbarControlColor ?? primaryManifest.primaryTextColor
        )
        
        hidesChooseLanguageControl = parallelLanguage == nil || primaryLanguage.id == parallelLanguage?.id
        
        chooseLanguageControlPrimaryLanguageTitle = primaryLanguage.translatedName(translateLanguageNameViewModel: translateLanguageNameViewModel)
        
        let parallelLocalizedName: String
        if let parallelLanguage = parallelLanguage {
            parallelLocalizedName = parallelLanguage.translatedName(translateLanguageNameViewModel: translateLanguageNameViewModel)
        }
        else {
            parallelLocalizedName = ""
        }
        
        chooseLanguageControlParallelLanguageTitle = parallelLocalizedName
        
        selectedTractLanguage = ObservableValue(value: TractLanguage(languageType: .primary, language: primaryLanguage))
        
        super.init()
        
        setupBinding()
        
        _ = viewsService.postNewResourceView(resourceId: resource.id)
                
        let startingTractPage: Int = tractPage ?? 0
        
        cacheTractPageIfNeeded(
            languageType: selectedTractLanguage.value.languageType,
            page: startingTractPage
        )
        
        loadTractXmlPages()
        
        tractPageDidChange(page: startingTractPage)
        tractPageDidAppear(page: startingTractPage)
        
        subscribeToLiveShareStream(liveShareStream: liveShareStream)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        tractRemoteShareSubscriber.navigationEventSignal.removeObserver(self)
        tractRemoteShareSubscriber.unsubscribe(disconnectSocket: true)
        destroyTractPages()
    }
    
    private func destroyTractPages() {
        
        // TODO: This shouldn't be necessary, but somehow TractPages are being retained so manually calling destroy on tract page
        // to remove all elements and views. ~Levi
        
        for ( _, tractPage) in cachedPrimaryTractPages {
            tractPage.destroyPage()
        }
        cachedPrimaryTractPages.removeAll()
        
        for ( _, tractPage) in cachedParallelTractPages {
            tractPage.destroyPage()
        }
        cachedParallelTractPages.removeAll()
    }
    
    private func setupBinding() {
        
        tractRemoteShareSubscriber.navigationEventSignal.addObserver(self) { [weak self] (navigationEvent: TractRemoteShareNavigationEvent) in
            DispatchQueue.main.async { [weak self] in
                self?.handleDidReceiveRemoteShareNavigationEvent(navigationEvent: navigationEvent)
            }
        }
    }
    
    private func subscribeToLiveShareStream(liveShareStream: String?) {
        
        guard let channelId = liveShareStream, !channelId.isEmpty else {
            return
        }
                
        tractRemoteShareSubscriber.subscribe(channelId: channelId) { [weak self] (error: TractRemoteShareSubscriberError?) in
            
        }
    }
    
    private func handleDidReceiveRemoteShareNavigationEvent(navigationEvent: TractRemoteShareNavigationEvent) {
        
        if let page = navigationEvent.page {
            cachedTractRemoteShareNavigationEvents[page] = navigationEvent
            currentTractPage.accept(value: AnimatableValue(value: page, animated: true))
            if let cachedTractPage = getTractPageItem(page: page).tractPage {
                cachedTractPage.setCard(card: navigationEvent.card, animated: true)
            }
        }
        
        if let locale = navigationEvent.locale, !locale.isEmpty {
            
            let currentTractLanguage: TractLanguage = selectedTractLanguage.value
            let localeChanged: Bool = locale != currentTractLanguage.language.code
            
            if localeChanged {
                if locale == primaryLanguage.code {
                    primaryLanguageTapped()
                }
                else if locale == parallelLanguage?.code {
                    parallelLanguagedTapped()
                }
            }
        }
    }
    
    private func loadTractXmlPages() {
        
        var tractItems: [TractXmlPageItem] = Array()
        
        for index in 0 ..< primaryTractXmlResource.pages.count {
            
            let primaryPage: XMLPage = primaryTractXmlResource.pages[index]
            let parallelPage: XMLPage?
            
            if let parallelTractXmlResource = parallelTractXmlResource, index >= 0 && index < parallelTractXmlResource.pages.count {
                parallelPage = parallelTractXmlResource.pages[index]
            }
            else {
                parallelPage = nil
            }
            
            tractItems.append(TractXmlPageItem(primaryXmlPage: primaryPage, parallelXmlPage: parallelPage))
        }
        
        tractXmlPageItems.accept(value: tractItems)
    }
    
    static private func parallelLanguageIsValid(resource: DownloadedResource, primaryLanguage: Language, parallelLanguage: Language?) -> Bool {
                
        let parallelLanguageIsPrimaryLanguage: Bool = primaryLanguage.code == parallelLanguage?.code
        
        var parallelLanguageTranslationExists: Bool = false
        if let parallelLanguageCode = parallelLanguage?.code {
            for translation in resource.translations {
                if let languageCode = translation.language?.code {
                    if languageCode == parallelLanguageCode {
                        parallelLanguageTranslationExists = true
                        break
                    }
                }
            }
        }
        
        return !parallelLanguageIsPrimaryLanguage && parallelLanguageTranslationExists
    }
    
    var isRightToLeftLanguage: Bool {
        switch LanguageDirection.direction(language: primaryLanguage) {
        case .leftToRight:
            return false
        case .rightToLeft:
            return true
        }
    }
    
    var primaryTractManifest: ManifestProperties {
        return primaryTractXmlResource.manifestProperties
    }
    
    var primaryTractPages: [XMLPage] {
        return primaryTractXmlResource.pages
    }
    
    func navHomeTapped() {
        flowDelegate?.navigate(step: .homeTappedFromTract)
    }
    
    func shareTapped() {
        flowDelegate?.navigate(step: .shareMenuTappedFromTract(resource: resource, language: selectedTractLanguage.value.language, pageNumber: tractPage))
    }
    
    func primaryLanguageTapped() {
                                
        switchFromParallelTractPageToPrimaryTractPage(page: tractPage)
        
        trackTappedLanguage(language: primaryLanguage)
                
        selectedTractLanguage.accept(value: TractLanguage(languageType: .primary, language: primaryLanguage))
    }
    
    func parallelLanguagedTapped() {
        
        guard let parallelLanguage = parallelLanguage else {
            return
        }
        
        switchFromPrimaryTractPageToParallelTractPage(page: tractPage)
                
        trackTappedLanguage(language: parallelLanguage)
                
        selectedTractLanguage.accept(value: TractLanguage(languageType: .parallel, language: parallelLanguage))
    }
    
    private func trackTappedLanguage(language: LanguageModel) {
        
        let data: [AnyHashable: String] = [
            AdobeAnalyticsConstants.Keys.parallelLanguageToggle: "",
            AdobeAnalyticsProperties.CodingKeys.contentLanguageSecondary.rawValue: language.code,
            AdobeAnalyticsProperties.CodingKeys.siteSection.rawValue: resource.abbreviation
        ]
        
        analytics.trackActionAnalytics.trackAction(
            screenName: nil,
            actionName: AdobeAnalyticsConstants.Values.parallelLanguageToggle,
            data: data
        )
    }
    
    func viewLoaded() {
        
        toolOpenedAnalytics.trackFirstToolOpenedIfNeeded()
        toolOpenedAnalytics.trackToolOpened()
    }
    
    func tractPageDidChange(page: Int) {
        
        self.tractPage = page
        
        cacheSurroundingTractPagesIfNeeded(
            languageType: selectedTractLanguage.value.languageType,
            page: page
        )
        
        resetTractPagesOutsideOfBuffer(
            buffer: 1,
            currentPage: page
        )
    }
    
    func tractPageDidAppear(page: Int) {
                      
        self.tractPage = page
                        
        analytics.pageViewedAnalytics.trackPageView(
            screenName: resource.abbreviation + "-" + String(page),
            siteSection: resource.abbreviation,
            siteSubSection: ""
        )
    }
    
    func sendEmailTapped(subject: String?, message: String?, isHtml: Bool?) {
        flowDelegate?.navigate(step: .sendEmailTappedFromTract(subject: subject ?? "", message: message ?? "", isHtml: isHtml ?? false))
    }
    
    // MARK: - Switching Between Primary and Parallel Tract Pages
    
    private func switchFromPrimaryTractPageToParallelTractPage(page: Int) {
               
        let cachedPrimaryTractPage: TractPage? = getCachedTractPage(
            languageType: .primary,
            page: page
        )
        
        let newParallelTractPage: TractPage? = buildTractPageForLanguage(
            languageType: .parallel,
            page: page,
            parallelTractPage: cachedPrimaryTractPage
        )
        
        if let newParallelTractPage = newParallelTractPage {
            
            cacheTractPage(
                languageType: .parallel,
                page: page,
                tractPage: newParallelTractPage
            )
        }
    }
    
    private func switchFromParallelTractPageToPrimaryTractPage(page: Int) {
        
        let cachedParallelTractPage: TractPage? = getCachedTractPage(
            languageType: .parallel,
            page: page
        )
        
        let newPrimaryTractPage: TractPage? = buildTractPageForLanguage(
            languageType: .primary,
            page: page,
            parallelTractPage: cachedParallelTractPage
        )
        
        if let newPrimaryTractPage = newPrimaryTractPage {
            
            cacheTractPage(
                languageType: .primary,
                page: page,
                tractPage: newPrimaryTractPage
            )
        }
    }
    
    // MARK: - Resetting Tract Pages
    
    private func resetTractPagesOutsideOfBuffer(buffer: Int, currentPage: Int) {
                
        resetTractPagesOutsideOfBuffer(languageType: .primary, buffer: buffer, currentPage: currentPage)
        
        resetTractPagesOutsideOfBuffer(languageType: .parallel, buffer: buffer, currentPage: currentPage)
    }
    
    private func resetTractPagesOutsideOfBuffer(languageType: TractLanguageType, buffer: Int, currentPage: Int) {
        
        let tractPagesCache: [Int: TractPage]
        
        switch languageType {
        case .primary:
            tractPagesCache = cachedPrimaryTractPages
        case .parallel:
            tractPagesCache = cachedParallelTractPages
        }
        
        let tractPageKeys: [Int] = Array(tractPagesCache.keys)
                
        for key in tractPageKeys {
            let distance: Int = abs(currentPage - key)
            if distance > buffer {
                tractPagesCache[key]?.reset()
            }
        }
    }
    
    // MARK: - Building New Tract Pages
    
    private func buildTractPageForLanguage(languageType: TractLanguageType, page: Int, parallelTractPage: TractPage?) -> TractPage? {
        
        switch languageType {
        case .primary:
            return buildPrimaryTractPage(page: page, parallelTractPage: parallelTractPage)
        case .parallel:
            return buildParallelTractPage(page: page, parallelTractPage: parallelTractPage)
        }
    }
    
    private func buildPrimaryTractPage(page: Int, parallelTractPage: TractPage?) -> TractPage? {
        
        return buildTractPage(
            page: page,
            language: primaryLanguage,
            tractXmlResource: primaryTractXmlResource,
            tractManifest: primaryTractXmlResource.manifestProperties,
            parallelTractPage: parallelTractPage
        )
    }
    
    private func buildParallelTractPage(page: Int, parallelTractPage: TractPage?) -> TractPage? {
        
        if let parallelLanguage = parallelLanguage, let parallelTractXmlResource = parallelTractXmlResource {
            
            return buildTractPage(
                page: page,
                language: parallelLanguage,
                tractXmlResource: parallelTractXmlResource,
                tractManifest: parallelTractXmlResource.manifestProperties,
                parallelTractPage: parallelTractPage
            )
        }
        
        return nil
    }
    
    private func buildTractPage(page: Int, language: LanguageModel, tractXmlResource: TractXmlResource, tractManifest: ManifestProperties, parallelTractPage: TractPage?) -> TractPage? {
        
        let dependencyContainer = BaseTractElementDiContainer(
            followUpsService: followUpsService,
            analytics: analytics
        )
        
        let pages: [XMLPage] = tractXmlResource.pages
        
        if page >= 0 && page < pages.count {
            
            let xmlPage: XMLPage = pages[page]
            
            let config = TractConfigurations()
            config.defaultTextAlignment = .left
            config.pagination = xmlPage.pagination
            config.language = language
            config.resource = resource
            
            let tractPage = TractPage(
                startWithData: xmlPage.pageContent(),
                height: UIScreen.main.bounds.size.height,
                manifestProperties: tractManifest,
                configurations: config,
                parallelElement: parallelTractPage,
                dependencyContainer: dependencyContainer,
                isPrimaryRightToLeft: isRightToLeftLanguage
            )
            
            return tractPage
        }
        
        return nil
    }
    
    // MARK: - Cacheing Tract Pages
    
    private func cacheSurroundingTractPagesIfNeeded(languageType: TractLanguageType, page: Int) {
                
        cacheTractPageIfNeeded(languageType: languageType, page: page - 2)
        cacheTractPageIfNeeded(languageType: languageType, page: page - 1)
        cacheTractPageIfNeeded(languageType: languageType, page: page + 1)
        cacheTractPageIfNeeded(languageType: languageType, page: page + 2)
    }
    
    private func getTractPageCacheDictionary(languageType: TractLanguageType) -> [Int: TractPage] {
        switch languageType {
        case .primary:
            return cachedPrimaryTractPages
        case .parallel:
            return cachedParallelTractPages
        }
    }
    
    private func cacheTractPage(languageType: TractLanguageType, page: Int, tractPage: TractPage) {
        
        switch languageType {
        case .primary:
            cachedPrimaryTractPages[page] = tractPage
        case .parallel:
            cachedParallelTractPages[page] = tractPage
        }
    }
    
    private func getCachedTractPage(languageType: TractLanguageType, page: Int) -> TractPage? {
        return getTractPageCacheDictionary(languageType: languageType)[page]
    }
    
    private func cacheTractPageIfNeeded(languageType: TractLanguageType, page: Int) {
                            
        let cachedTract: TractPage? = getCachedTractPage(
            languageType: languageType,
            page: page
        )
        
        let tractIsCached: Bool = cachedTract != nil
        
        if !tractIsCached, let tractPage = buildTractPageForLanguage(languageType: languageType, page: page, parallelTractPage: nil) {
                        
            cacheTractPage(
                languageType: languageType,
                page: page,
                tractPage: tractPage
            )
        }
    }
    
    func getTractPageItem(page: Int) -> TractPageItem {
            
        let selectedLanguageType: TractLanguageType = selectedTractLanguage.value.languageType
        
        let tractPage: TractPage?
        let navigationEvent: TractRemoteShareNavigationEvent?
        
        if let cachedTractPage = getCachedTractPage(languageType: selectedLanguageType, page: page) {
            
            tractPage = cachedTractPage
        }
        else if let newTractPage = buildTractPageForLanguage(languageType: selectedLanguageType, page: page, parallelTractPage: nil) {
            
            tractPage = newTractPage
            
            cacheTractPage(
                languageType: selectedLanguageType,
                page: page,
                tractPage: newTractPage
            )
        }
        else {
            
            tractPage = nil
        }
        
        if let cachedNavigationEvent = cachedTractRemoteShareNavigationEvents[page] {
            navigationEvent = cachedNavigationEvent
        }
        else {
            navigationEvent = nil
        }
        
        return TractPageItem(tractPage: tractPage, navigationEvent: navigationEvent)
    }
}
