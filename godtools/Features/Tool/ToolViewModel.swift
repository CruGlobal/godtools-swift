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
    typealias LanguageCode = String
    
    private let resource: ResourceModel
    private let languages: [LanguageModel]
    private let primaryLanguageTranslationModel: ToolLanguageTranslationModel
    private let parallelLanguageTranslationModel: ToolLanguageTranslationModel?
    private let languageTranslationModels: [ToolLanguageTranslationModel]
    private let currentPagesViewModelsCache: ToolPageViewModelsCache = ToolPageViewModelsCache()
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
    private let viewedTrainingTips: ViewedTrainingTipsService
    private let trainingTipsEnabled: Bool
    
    private var navBarViewModel: ToolNavBarViewModel!
    private var lastToolPagePositionsForLanguageChange: ToolPageInitialPositions?
        
    let currentPage: ObservableValue<AnimatableValue<Int>> = ObservableValue(value: AnimatableValue(value: 0, animated: false))
    let numberOfToolPages: ObservableValue<Int> = ObservableValue(value: 0)
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, primaryLanguage: LanguageModel, parallelLanguage: LanguageModel?, primaryTranslationManifestData: TranslationManifestData, parallelTranslationManifestData: TranslationManifestData?, mobileContentNodeParser: MobileContentXmlNodeParser, mobileContentAnalytics: MobileContentAnalytics, mobileContentEvents: MobileContentEvents, translationsFileCache: TranslationsFileCache, languageSettingsService: LanguageSettingsService, fontService: FontService, tractRemoteSharePublisher: TractRemoteSharePublisher, tractRemoteShareSubscriber: TractRemoteShareSubscriber, isNewUserService: IsNewUserService, cardJumpService: CardJumpService, followUpsService: FollowUpsService, viewsService: ViewsService, localizationServices: LocalizationServices, analytics: AnalyticsContainer, toolOpenedAnalytics: ToolOpenedAnalytics, liveShareStream: String?, viewedTrainingTips: ViewedTrainingTipsService, trainingTipsEnabled: Bool, page: Int?) {
                
        self.flowDelegate = flowDelegate
        self.resource = resource
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
        self.viewedTrainingTips = viewedTrainingTips
        self.trainingTipsEnabled = trainingTipsEnabled
        
        let primaryLanguageTranslationModel = ToolLanguageTranslationModel(
            language: primaryLanguage,
            translationManifestData: primaryTranslationManifestData,
            translationsFileCache: translationsFileCache,
            mobileContentNodeParser: mobileContentNodeParser
        )
        
        self.primaryLanguageTranslationModel = primaryLanguageTranslationModel
                
        let parallelLanguageIsEqualToPrimaryLanguage: Bool
        if let parallelLanguage = parallelLanguage {
            parallelLanguageIsEqualToPrimaryLanguage = parallelLanguage.code.lowercased() == primaryLanguage.code.lowercased()
        }
        else {
            parallelLanguageIsEqualToPrimaryLanguage = false
        }
        
        if !parallelLanguageIsEqualToPrimaryLanguage, let parallelLanguage = parallelLanguage, let parallelTranslationManifestData = parallelTranslationManifestData {
            
            let parallelLanguageTranslationModel = ToolLanguageTranslationModel(
                language: parallelLanguage,
                translationManifestData: parallelTranslationManifestData,
                translationsFileCache: translationsFileCache,
                mobileContentNodeParser: mobileContentNodeParser
            )
            
            self.parallelLanguageTranslationModel = parallelLanguageTranslationModel
                        
            languageTranslationModels = [primaryLanguageTranslationModel, parallelLanguageTranslationModel]
            
            languages = [primaryLanguage, parallelLanguage]
        }
        else {
            
            self.parallelLanguageTranslationModel = nil
            
            languageTranslationModels = [primaryLanguageTranslationModel]
            
            languages = [primaryLanguage]
        }
        
        super.init()
        
        self.navBarViewModel = ToolNavBarViewModel(
            delegate: self,
            resource: resource,
            manifestAttributes: languageTranslationModels[0].manifest.attributes,
            languages: languages,
            tractRemoteSharePublisher: tractRemoteSharePublisher,
            tractRemoteShareSubscriber: tractRemoteShareSubscriber,
            localizationServices: localizationServices,
            analytics: analytics,
            hidesShareButton: trainingTipsEnabled
        )
                                                        
        setupBinding()
                
        let startingToolPage: Int = page ?? 0
            
        forceToolRefresh(language: 0, page: startingToolPage, card: nil)
        
        toolPageDidChange(page: startingToolPage)
        toolPageDidAppear(page: startingToolPage)
        
        subscribeToLiveShareStreamIfNeeded(liveShareStream: liveShareStream)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        currentPagesViewModelsCache.clearCache()
        mobileContentEvents.urlButtonTappedSignal.removeObserver(self)
        tractRemoteSharePublisher.didCreateNewSubscriberChannelIdForPublish.removeObserver(self)
        tractRemoteSharePublisher.endPublishingSession(disconnectSocket: true)
        tractRemoteShareSubscriber.navigationEventSignal.removeObserver(self)
        tractRemoteShareSubscriber.unsubscribe(disconnectSocket: true)
    }
    
    private func setupBinding() {
        
        mobileContentEvents.urlButtonTappedSignal.addObserver(self) { [weak self] (urlButtonEvent: UrlButtonEvent) in
            guard let url = URL(string: urlButtonEvent.url) else {
                return
            }
            self?.flowDelegate?.navigate(step: .urlLinkTappedFromTool(url: url))
        }
        
        var isFirstRemoteShareNavigationEvent: Bool = true
        
        tractRemoteSharePublisher.didCreateNewSubscriberChannelIdForPublish.addObserver(self) { [weak self] (channel: TractRemoteShareChannel) in
            DispatchQueue.main.async { [weak self] in
                if let currentToolPage = self?.currentToolPage {
                   self?.sendRemoteShareNavigationEventForPage(page: currentToolPage)
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
    
    private func trackShareScreenOpened() {
        
        analytics.trackActionAnalytics.trackAction(screenName: "", actionName: "Share Screen Opened", data: ["cru.share_screen_open": 1])
    }
    
    func viewLoaded() {
        
        _ = viewsService.postNewResourceView(resourceId: resource.id)
        
        toolOpenedAnalytics.trackFirstToolOpenedIfNeeded()
        toolOpenedAnalytics.trackToolOpened()
    }
    
    func navBarWillAppear() -> ToolNavBarViewModelType {
                      
        return navBarViewModel
    }
}

// MARK: - Remote Share Subscriber / Publisher

extension ToolViewModel {
    
    private func subscribeToLiveShareStreamIfNeeded(liveShareStream: String?) {
        
        guard let channelId = liveShareStream, !channelId.isEmpty else {
            return
        }
                
        tractRemoteShareSubscriber.subscribe(channelId: channelId) { [weak self] (error: TractRemoteShareSubscriberError?) in
            DispatchQueue.main.async { [weak self] in
                self?.trackShareScreenOpened()
            }
        }
    }
    
    private func handleDidReceiveRemoteShareNavigationEvent(navigationEvent: TractRemoteShareNavigationEvent, animated: Bool = true) {
        
        let attributes = navigationEvent.message?.data?.attributes
        
        var navigateToLanguage: Int?
        let navigateToPage: Int? = attributes?.page
        let navigateToCard: Int? = attributes?.card
        
        if let locale = attributes?.locale, !locale.isEmpty {
            for index in 0 ..< languages.count {
                if locale.lowercased() == languages[index].code.lowercased() {
                    navigateToLanguage = index
                }
            }
        }
        
        setToolPage(
            language: navigateToLanguage,
            page: navigateToPage ?? currentToolPage,
            card: navigateToCard,
            animated: animated
        )
    }
    
    private func sendRemoteShareNavigationEventForPage(page: Int) {
        
        guard tractRemoteSharePublisher.isSubscriberChannelIdCreatedForPublish else {
            return
        }
        
        let currentToolPagePositions: ToolPageInitialPositions? = currentPagesViewModelsCache.getPage(page: page)?.getCurrentPositions()
        let language: LanguageModel = languages[currentToolLanguage]
        
        let event = TractRemoteSharePublisherNavigationEvent(
            card: currentToolPagePositions?.card,
            locale: language.code,
            page: page,
            tool: resource.abbreviation
        )
        
        tractRemoteSharePublisher.sendNavigationEvent(event: event)
    }
}

// MARK: - Tool Pages

extension ToolViewModel {
    
    private func setToolPage(language: Int?, page: Int, card: Int?, animated: Bool) {
                        
        guard let newLanguageIndex = language, newLanguageIndex != currentToolLanguage else {
            setToolPage(page: page, card: card, animated: animated)
            return
        }
        
        forceToolRefresh(language: newLanguageIndex, page: page, card: card)
    }
    
    private func forceToolRefresh(language: Int, page: Int, card: Int?) {
                
        // clear cache on force refresh
        currentPagesViewModelsCache.clearCache()
        
        let initialPositions: ToolPageInitialPositions?
        
        if let card = card {
            initialPositions = ToolPageInitialPositions(page: page, card: card)
        }
        else {
            initialPositions = nil
        }
        
        // cache new positions
        _ = getAndCacheToolPageViewModel(page: page, language: language, initialPositions: initialPositions)
                    
        // update languages control in navbar
        navBarViewModel.selectedLanguage.accept(value: language)
        
        numberOfToolPages.accept(value: languageTranslationModels[language].manifest.pages.count)
        
        currentPage.accept(value: AnimatableValue(value: page, animated: false))
    }
    
    private func setToolPage(page: Int, card: Int?, animated: Bool) {
        
        let pageViewModel: ToolPageViewModelType?
        
        if let cachedPageViewModel = currentPagesViewModelsCache.getPage(page: page) {
            pageViewModel = cachedPageViewModel
        }
        else {
            pageViewModel = getAndCacheToolPageViewModel(page: page, language: currentToolLanguage, initialPositions: ToolPageInitialPositions(page: page, card: card))
        }
        
        pageViewModel?.setCard(cardPosition: card, animated: animated)
        
        if page != currentToolPage {
            currentPage.accept(value: AnimatableValue(value: page, animated: animated))
        }
    }
    
    private var currentToolLanguage: Int {
        return navBarViewModel.selectedLanguage.value
    }
    
    private var currentToolPage: Int {
        get {
            return currentPage.value.value
        }
        set(newValue) {
            currentPage.setValue(value: AnimatableValue(value: newValue, animated: false))
        }
    }
    
    private func getAndCacheToolPageViewModel(page: Int, language: Int, initialPositions: ToolPageInitialPositions?) -> ToolPageViewModelType? {
        
        let languageTranslationModel: ToolLanguageTranslationModel = languageTranslationModels[language]
        
        if let pageNode = languageTranslationModel.getToolPageNode(page: page) {
                                                             
            let toolPageDiContainer = ToolPageDiContainer(
                manifest: languageTranslationModel.manifest,
                resource: resource,
                language: languageTranslationModel.language,
                primaryLanguage: primaryLanguageTranslationModel.language,
                translationsFileCache: translationsFileCache,
                mobileContentNodeParser: mobileContentNodeParser,
                mobileContentAnalytics: mobileContentAnalytics,
                mobileContentEvents: mobileContentEvents,
                analytics: analytics,
                fontService: fontService,
                followUpsService: followUpsService,
                localizationServices: localizationServices,
                cardJumpService: cardJumpService,
                viewedTrainingTips: viewedTrainingTips,
                trainingTipsEnabled: trainingTipsEnabled
            )
            
            let viewModel = ToolPageViewModel(
                delegate: self,
                pageNode: pageNode,
                diContainer: toolPageDiContainer,
                page: page,
                initialPositions: initialPositions
            )
            
            currentPagesViewModelsCache.cachePage(page: page, toolPageViewModel: viewModel)
                                               
            return viewModel
        }
        
        return nil
    }
    
    func toolPageWillAppear(page: Int) -> ToolPageViewModelType? {
        
        if let cachedToolPageViewModel = currentPagesViewModelsCache.getPage(page: page) {
            
            return cachedToolPageViewModel
        }
        
        return getAndCacheToolPageViewModel(page: page, language: currentToolLanguage, initialPositions: nil)
    }
    
    func toolPageDidChange(page: Int) {
        
        self.currentToolPage = page
                        
        sendRemoteShareNavigationEventForPage(page: page)
    }
    
    func toolPageDidAppear(page: Int) {
                      
        self.currentToolPage = page
        
        currentPagesViewModelsCache.getPage(page: page)?.pageDidAppear()
        
        currentPagesViewModelsCache.deleteAllPagesOutsideBufferFromPage(page: page, buffer: 2)
                                        
        analytics.pageViewedAnalytics.trackPageView(
            screenName: resource.abbreviation + "-" + String(page),
            siteSection: resource.abbreviation,
            siteSubSection: ""
        )
    }
    
    func toolPageDidDisappear(page: Int) {
        
        currentPagesViewModelsCache.getPage(page: page)?.pageDidDisappear()
    }
    
    func gotoNextPage(animated: Bool) {
        
        let nextPage: Int = currentToolPage + 1
        
        if nextPage < numberOfToolPages.value {
            currentPage.accept(value: AnimatableValue(value: nextPage, animated: animated))
        }
    }
}

// MARK: - ToolNavBarViewModelDelegate

extension ToolViewModel: ToolNavBarViewModelDelegate {
    
    func navHomeTapped(navBar: ToolNavBarViewModelType) {
        flowDelegate?.navigate(step: .homeTappedFromTool(isScreenSharing: navBar.remoteShareIsActive.value))
    }
    
    func shareTapped(navBar: ToolNavBarViewModelType) {

        let pageNumber: Int = currentPage.value.value
        let selectedLanguage: LanguageModel = navBar.language
        let primaryLanguage: LanguageModel = primaryLanguageTranslationModel.language
        let parallelLanguage: LanguageModel? = parallelLanguageTranslationModel?.language
            
        flowDelegate?.navigate(step: .shareMenuTappedFromTool(tractRemoteShareSubscriber: tractRemoteShareSubscriber, tractRemoteSharePublisher: tractRemoteSharePublisher, resource: resource, selectedLanguage: selectedLanguage, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, pageNumber: pageNumber))
    }
    
    func languageTapped(navBar: ToolNavBarViewModelType, previousLanguage: Int, newLanguage: Int) {
           
        let currentToolPagePositions: ToolPageInitialPositions? = currentPagesViewModelsCache.getPage(page: currentToolPage)?.getCurrentPositions()
        
        forceToolRefresh(language: newLanguage, page: currentToolPage, card: currentToolPagePositions?.card)
                
        sendRemoteShareNavigationEventForPage(page: currentToolPage)
    }
}

// MARK: - ToolPageViewModelTypeDelegate

extension ToolViewModel: ToolPageViewModelTypeDelegate {
    
    func toolPagePresentedListener(viewModel: ToolPageViewModelType, page: Int) {
        
        currentPage.accept(value: AnimatableValue(value: page, animated: true))
    }
    
    func toolPageTrainingTipTapped(trainingTipId: String, tipNode: TipNode) {
        
        let languageTranslationModel: ToolLanguageTranslationModel = languageTranslationModels[currentToolLanguage]
        
        flowDelegate?.navigate(step: .toolTrainingTipTappedFromTool(resource: resource, manifest: languageTranslationModel.manifest, trainingTipId: trainingTipId, tipNode: tipNode, language: languageTranslationModel.language, primaryLanguage: primaryLanguageTranslationModel.language))
    }
    
    func toolPageCardChanged(cardPosition: Int?) {
        
        sendRemoteShareNavigationEventForPage(page: currentToolPage)
    }
    
    func toolPageNextPageTapped() {
        
        gotoNextPage(animated: true)
    }
    
    func toolPageError(error: ContentEventError) {
        
        flowDelegate?.navigate(step: .toolDidEncounterErrorFromTool(error: error))
    }
}
