//
//  ToolViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolViewModel: NSObject, ToolViewModelType {
    
    typealias PageNumber = Int
    
    private let resource: ResourceModel
    private let primaryLanguage: LanguageModel
    private let parallelLanguage: LanguageModel?
    private let primaryTranslationManifest: MobileContentXmlManifest
    private let mobileContentNodeParser: MobileContentXmlNodeParser
    private let mobileContentAnalytics: MobileContentAnalytics
    private let mobileContentEvents: MobileContentEvents
    private let translationsFileCache: TranslationsFileCache
    private let tractRemoteSharePublisher: TractRemoteSharePublisher
    private let tractRemoteShareSubscriber: TractRemoteShareSubscriber
    private let isNewUserService: IsNewUserService
    private let cardJumpService: CardJumpService
    private let followUpsService: FollowUpsService
    private let viewsService: ViewsService
    private let localizationServices: LocalizationServices
    private let fontService: FontService
    private let analytics: AnalyticsContainer
    private let toolOpenedAnalytics: ToolOpenedAnalytics
    
    private var cachedPrimaryPageNodes: [PageNumber: PageNode] = Dictionary()
    private var cachedTractRemoteShareNavigationEvents: [PageNumber: TractRemoteShareNavigationEvent] = Dictionary()
    private var toolPage: Int = 0
        
    let navBarViewModel: ToolNavBarViewModel
    let selectedToolLanguage: ObservableValue<TractLanguage>
    let currentPage: ObservableValue<AnimatableValue<Int>> = ObservableValue(value: AnimatableValue(value: 0, animated: false))
    let remoteShareIsActive: ObservableValue<Bool> = ObservableValue(value: false)
    let numberOfToolPages: ObservableValue<Int> = ObservableValue(value: 0)
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, primaryLanguage: LanguageModel, parallelLanguage: LanguageModel?, primaryTranslationManifestData: TranslationManifestData, parallelTranslationManifestData: TranslationManifestData?, mobileContentNodeParser: MobileContentXmlNodeParser, mobileContentAnalytics: MobileContentAnalytics, mobileContentEvents: MobileContentEvents, translationsFileCache: TranslationsFileCache, languageSettingsService: LanguageSettingsService, fontService: FontService, tractRemoteSharePublisher: TractRemoteSharePublisher, tractRemoteShareSubscriber: TractRemoteShareSubscriber, isNewUserService: IsNewUserService, cardJumpService: CardJumpService, followUpsService: FollowUpsService, viewsService: ViewsService, localizationServices: LocalizationServices, analytics: AnalyticsContainer, toolOpenedAnalytics: ToolOpenedAnalytics, liveShareStream: String?, toolPage: Int?) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.primaryLanguage = primaryLanguage
        self.parallelLanguage = parallelLanguage?.code != primaryLanguage.code ? parallelLanguage : nil
        self.primaryTranslationManifest = MobileContentXmlManifest(translationManifest: primaryTranslationManifestData)
        self.mobileContentNodeParser = mobileContentNodeParser
        self.mobileContentAnalytics = mobileContentAnalytics
        self.mobileContentEvents = mobileContentEvents
        self.translationsFileCache = translationsFileCache
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        self.tractRemoteShareSubscriber = tractRemoteShareSubscriber
        self.isNewUserService = isNewUserService
        self.cardJumpService = cardJumpService
        self.followUpsService = followUpsService
        self.viewsService = viewsService
        self.localizationServices = localizationServices
        self.fontService = fontService
        self.analytics = analytics
        self.toolOpenedAnalytics = toolOpenedAnalytics
        
        self.navBarViewModel = ToolNavBarViewModel(
            manifestAttributes: primaryTranslationManifest.attributes,
            primaryLanguage: primaryLanguage,
            parallelLanguage: parallelLanguage,
            localizationServices: localizationServices
        )
                                        
        selectedToolLanguage = ObservableValue(value: TractLanguage(languageType: .primary, language: primaryLanguage))
        
        super.init()
        
        setupBinding()
        
        _ = viewsService.postNewResourceView(resourceId: resource.id)
                
        let startingToolPage: Int = toolPage ?? 0
                
        numberOfToolPages.accept(value: primaryTranslationManifest.pages.count)
        
        toolPageDidChange(page: startingToolPage)
        toolPageDidAppear(page: startingToolPage)
        
        subscribeToLiveShareStream(liveShareStream: liveShareStream)
        
        reloadRemoteShareIsActive()
        
        addEventListeners()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        removeEventListeners()
        tractRemoteSharePublisher.didCreateNewSubscriberChannelIdForPublish.removeObserver(self)
        tractRemoteSharePublisher.endPublishingSession(disconnectSocket: true)
        tractRemoteShareSubscriber.navigationEventSignal.removeObserver(self)
        tractRemoteShareSubscriber.unsubscribe(disconnectSocket: true)
    }
    
    func addEventListeners() {
        
        mobileContentEvents.urlButtonTappedSignal.addObserver(self) { [weak self] (urlButtonEvent: UrlButtonEvent) in
            guard let url = URL(string: urlButtonEvent.url) else {
                return
            }
            self?.flowDelegate?.navigate(step: .urlLinkTappedFromTool(url: url))
        }
    }
    
    func removeEventListeners() {
        
        mobileContentEvents.urlButtonTappedSignal.removeObserver(self)
    }
        
    private func setupBinding() {
        
        var isFirstRemoteShareNavigationEvent: Bool = true
        
        tractRemoteSharePublisher.didCreateNewSubscriberChannelIdForPublish.addObserver(self) { [weak self] (channel: TractRemoteShareChannel) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadRemoteShareIsActive()
                if let toolPage = self?.toolPage {
                   self?.sendRemoteShareNavigationEventForPage(page: toolPage)
                }
            }
        }
        
        tractRemoteShareSubscriber.navigationEventSignal.addObserver(self) { [weak self] (navigationEvent: TractRemoteShareNavigationEvent) in
            DispatchQueue.main.async { [weak self] in
                let animated: Bool = !isFirstRemoteShareNavigationEvent
                self?.handleDidReceiveRemoteShareNavigationEvent(navigationEvent: navigationEvent, animated: animated)
                isFirstRemoteShareNavigationEvent = false
            }
        }
    }
    
    private func subscribeToLiveShareStream(liveShareStream: String?) {
        
        guard let channelId = liveShareStream, !channelId.isEmpty else {
            return
        }
                
        tractRemoteShareSubscriber.subscribe(channelId: channelId) { [weak self] (error: TractRemoteShareSubscriberError?) in
            DispatchQueue.main.async { [weak self] in
                self?.trackShareScreenOpened()
                self?.reloadRemoteShareIsActive()
            }
        }
    }
    
    private func trackShareScreenOpened() {
        
        analytics.trackActionAnalytics.trackAction(screenName: "", actionName: "Share Screen Opened", data: ["cru.share_screen_open": 1])
    }
    
    private func handleDidReceiveRemoteShareNavigationEvent(navigationEvent: TractRemoteShareNavigationEvent, animated: Bool = true) {
        
        /*
        let attributes = navigationEvent.message?.data?.attributes
        
        if let page = attributes?.page {
            cachedTractRemoteShareNavigationEvents[page] = navigationEvent
            currentPage.accept(value: AnimatableValue(value: page, animated: animated))
            if let cachedTractPage = getTractPageItem(page: page).tractPage {
                cachedTractPage.setCard(card: attributes?.card, animated: animated)
            }
        }
        
        if let locale = attributes?.locale, !locale.isEmpty {
            
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
        }*/
    }
    
    private func sendRemoteShareNavigationEventForPage(page: Int) {
        
        if tractRemoteSharePublisher.isSubscriberChannelIdCreatedForPublish {
            /*
            let tractPageItem: TractPageItem = getTractPageItem(page: page)
            
            tractRemoteSharePublisher.sendNavigationEvent(
                card: tractPageItem.tractPage?.openedCard,
                locale: selectedTractLanguage.value.language.code,
                page: page,
                tool: resource.abbreviation
            )*/
        }
    }
    
    private func reloadRemoteShareIsActive() {
        
        let isActive: Bool = tractRemoteSharePublisher.isSubscriberChannelIdCreatedForPublish || tractRemoteShareSubscriber.isSubscribedToChannel
        
        remoteShareIsActive.accept(value: isActive)
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
        switch primaryLanguage.languageDirection {
        case .leftToRight:
            return false
        case .rightToLeft:
            return true
        }
    }
    
    func navHomeTapped() {
        flowDelegate?.navigate(step: .homeTappedFromTool(isScreenSharing: remoteShareIsActive.value))
    }
    
    func shareTapped() {
        flowDelegate?.navigate(step: .shareMenuTappedFromTool(tractRemoteShareSubscriber: tractRemoteShareSubscriber, tractRemoteSharePublisher: tractRemoteSharePublisher, resource: resource, selectedLanguage: selectedToolLanguage.value.language, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, pageNumber: toolPage))
    }
    
    func primaryLanguageTapped() {
                                
        //switchFromParallelTractPageToPrimaryTractPage(page: toolPage)
        
        trackTappedLanguage(language: primaryLanguage)
                
        selectedToolLanguage.accept(value: TractLanguage(languageType: .primary, language: primaryLanguage))
        
        sendRemoteShareNavigationEventForPage(page: toolPage)
    }
    
    func parallelLanguagedTapped() {
        
        guard let parallelLanguage = parallelLanguage else {
            return
        }
        
        //switchFromPrimaryTractPageToParallelTractPage(page: toolPage)
                
        trackTappedLanguage(language: parallelLanguage)
                
        selectedToolLanguage.accept(value: TractLanguage(languageType: .parallel, language: parallelLanguage))
        
        sendRemoteShareNavigationEventForPage(page: toolPage)
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
    
    private func getToolPageNode(page: Int) -> PageNode? {
        
        let manifestPage: MobileContentXmlManifestPage = primaryTranslationManifest.pages[page]
        let pageXmlCacheLocation: SHA256FileLocation = SHA256FileLocation(sha256WithPathExtension: manifestPage.src)
        
        let pageXml: Data?
        let pageNode: PageNode?
        
        if let cachedPageNode = cachedPrimaryPageNodes[page] {
            pageNode = cachedPageNode
        }
        else {

            switch translationsFileCache.getData(location: pageXmlCacheLocation) {
                
            case .success(let pageXmlData):
                pageXml = pageXmlData
            case .failure(let error):
                pageXml = nil
            }
            
            // TODO: Would it be better to return page xml and have tool pages build themselves as nodes are built? ~Levi
            
            guard let pageXmlData = pageXml else {
                return nil
            }
            
            pageNode = mobileContentNodeParser.parse(xml: pageXmlData, delegate: nil) as? PageNode
        }
        
        return pageNode
    }
    
    func viewLoaded() {
        
        toolOpenedAnalytics.trackFirstToolOpenedIfNeeded()
        toolOpenedAnalytics.trackToolOpened()
    }
    
    func toolPageWillAppear(page: Int) -> ToolPageViewModel? {
        
        // TODO: Need to add better error handling. ~Levi
        
        let manifestPage: MobileContentXmlManifestPage = primaryTranslationManifest.pages[page]
        let pageXmlCacheLocation: SHA256FileLocation = SHA256FileLocation(sha256WithPathExtension: manifestPage.src)
                
        let pageXml: Data?
        let pageNode: PageNode?
        
        if let cachedPageNode = cachedPrimaryPageNodes[page] {
            pageNode = cachedPageNode
        }
        else {

            switch translationsFileCache.getData(location: pageXmlCacheLocation) {
                
            case .success(let pageXmlData):
                pageXml = pageXmlData
            case .failure(let error):
                pageXml = nil
            }
                        
            guard let pageXmlData = pageXml else {
                return nil
            }
            
            pageNode = mobileContentNodeParser.parse(xml: pageXmlData, delegate: nil) as? PageNode
        }
        
        if let pageNode = pageNode {
            
            cachedPrimaryPageNodes[page] = pageNode
                                
            let viewModel = ToolPageViewModel(
                delegate: self,
                pageNode: pageNode,
                manifest: primaryTranslationManifest,
                language: primaryLanguage,
                translationsFileCache: translationsFileCache,
                mobileContentAnalytics: mobileContentAnalytics,
                mobileContentEvents: mobileContentEvents,
                fontService: fontService,
                followUpsService: followUpsService,
                localizationServices: localizationServices,
                page: page
            )
            
            return viewModel
        }
        
        return nil
    }
    
    func toolPageDidChange(page: Int) {
        
        self.toolPage = page
        
        sendRemoteShareNavigationEventForPage(page: page)
    }
    
    func toolPageDidAppear(page: Int) {
                      
        self.toolPage = page
                                
        analytics.pageViewedAnalytics.trackPageView(
            screenName: resource.abbreviation + "-" + String(page),
            siteSection: resource.abbreviation,
            siteSubSection: ""
        )
    }
    
    func gotoNextPage(animated: Bool) {
        
        let nextPage: Int = toolPage + 1
        
        if nextPage < numberOfToolPages.value {
            currentPage.accept(value: AnimatableValue(value: nextPage, animated: animated))
        }
    }
    
    func tractPageCardStateChanged(cardState: TractCardProperties.CardState) {
        
        if cardState == .open || cardState == .close {
            
            sendRemoteShareNavigationEventForPage(page: toolPage)
        }
    }
    
    func sendEmailTapped(subject: String?, message: String?, isHtml: Bool?) {
        flowDelegate?.navigate(step: .sendEmailTappedFromTool(subject: subject ?? "", message: message ?? "", isHtml: isHtml ?? false))
    }
}

// MARK: - ToolPageViewModelDelegate

extension ToolViewModel: ToolPageViewModelDelegate {
    
    func toolPagePresented(viewModel: ToolPageViewModel, page: Int) {
        currentPage.accept(value: AnimatableValue(value: page, animated: true))
    }
    
    func toolPageNextPageTapped() {
        
        gotoNextPage(animated: true)
    }
    
    func toolPageError(error: ContentEventError) {
        
        flowDelegate?.navigate(step: .toolDidEncounterErrorFromTool(error: error))
    }
}
