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
    private let primaryLanguageTranslationModel: ToolLanguageTranslationModel
    private let parallelLanguageTranslationModel: ToolLanguageTranslationModel?
    private let languageTranslationModels: [ToolLanguageTranslationModel]
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
    
    private var navBarViewModel: ToolNavBarViewModelType?
    private var lastToolPagePositionsForLanguageChange: ToolPageInitialPositions?
    private var cachedToolRemoteShareNavigationEvents: [PageNumber: TractRemoteShareNavigationEvent] = Dictionary()
        
    let currentPage: ObservableValue<AnimatableValue<Int>> = ObservableValue(value: AnimatableValue(value: 0, animated: false))
    let numberOfToolPages: ObservableValue<Int> = ObservableValue(value: 0)
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, primaryLanguage: LanguageModel, parallelLanguage: LanguageModel?, primaryTranslationManifestData: TranslationManifestData, parallelTranslationManifestData: TranslationManifestData?, mobileContentNodeParser: MobileContentXmlNodeParser, mobileContentAnalytics: MobileContentAnalytics, mobileContentEvents: MobileContentEvents, translationsFileCache: TranslationsFileCache, languageSettingsService: LanguageSettingsService, fontService: FontService, tractRemoteSharePublisher: TractRemoteSharePublisher, tractRemoteShareSubscriber: TractRemoteShareSubscriber, isNewUserService: IsNewUserService, cardJumpService: CardJumpService, followUpsService: FollowUpsService, viewsService: ViewsService, localizationServices: LocalizationServices, analytics: AnalyticsContainer, toolOpenedAnalytics: ToolOpenedAnalytics, liveShareStream: String?, page: Int?) {
                
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
        
        let primaryLanguageTranslationModel = ToolLanguageTranslationModel(
            language: primaryLanguage,
            translationManifestData: primaryTranslationManifestData,
            translationsFileCache: translationsFileCache,
            mobileContentNodeParser: mobileContentNodeParser
        )
        
        self.primaryLanguageTranslationModel = primaryLanguageTranslationModel
        
        if let parallelLanguage = parallelLanguage, let parallelTranslationManifestData = parallelTranslationManifestData {
            
            let parallelLanguageTranslationModel = ToolLanguageTranslationModel(
                language: parallelLanguage,
                translationManifestData: parallelTranslationManifestData,
                translationsFileCache: translationsFileCache,
                mobileContentNodeParser: mobileContentNodeParser
            )
            
            self.parallelLanguageTranslationModel = parallelLanguageTranslationModel
                        
            languageTranslationModels = [primaryLanguageTranslationModel, parallelLanguageTranslationModel]
        }
        else {
            
            self.parallelLanguageTranslationModel = nil
            
            languageTranslationModels = [primaryLanguageTranslationModel]
        }
                                                        
        super.init()
        
        setupBinding()
                
        let startingToolPage: Int = page ?? 0
                
        toolPageDidChange(page: startingToolPage)
        toolPageDidAppear(page: startingToolPage)
        
        subscribeToLiveShareStreamIfNeeded(liveShareStream: liveShareStream)
        
        reloadTool()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
    
    private func trackShareScreenOpened() {
        
        analytics.trackActionAnalytics.trackAction(screenName: "", actionName: "Share Screen Opened", data: ["cru.share_screen_open": 1])
    }
    
    private func handleDidReceiveRemoteShareNavigationEvent(navigationEvent: TractRemoteShareNavigationEvent, animated: Bool = true) {
        
        let attributes = navigationEvent.message?.data?.attributes
        
        if let page = attributes?.page {
            
            currentPage.accept(value: AnimatableValue(value: page, animated: animated))
            
            
            //cachedToolRemoteShareNavigationEvents[page] = navigationEvent
            
            
            /*
            if let cachedTractPage = getTractPageItem(page: page).tractPage {
                cachedTractPage.setCard(card: attributes?.card, animated: animated)
            }*/
        }
        
        /*
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
            
            // TODO: Need to get tool page card position.
            
            /*
            let event = TractRemoteSharePublisherNavigationEvent(
                card: tractPageItem.tractPage?.openedCard,
                locale: selectedToolLanguage.value.language.code,
                page: page,
                tool: resource.abbreviation
            )
            
            tractRemoteSharePublisher.sendNavigationEvent(event: event)*/
        }
    }
    
    var backgroundColor: UIColor {
        let manifestAttributes: MobileContentManifestAttributesType = primaryLanguageTranslationModel.manifest.attributes
        return manifestAttributes.getNavBarColor()?.color ?? manifestAttributes.getPrimaryColor().color
    }
    
    var isRightToLeftLanguage: Bool {
        switch primaryLanguageTranslationModel.language.languageDirection {
        case .leftToRight:
            return false
        case .rightToLeft:
            return true
        }
    }
    
    func viewLoaded() {
        
        _ = viewsService.postNewResourceView(resourceId: resource.id)
        
        toolOpenedAnalytics.trackFirstToolOpenedIfNeeded()
        toolOpenedAnalytics.trackToolOpened()
    }
    
    func navBarWillAppear() -> ToolNavBarViewModelType {
        
        let languages: [LanguageModel] = languageTranslationModels.map({$0.language})
        
        let navBarViewModel = ToolNavBarViewModel(
            delegate: self,
            resource: resource,
            manifestAttributes: languageTranslationModels[0].manifest.attributes,
            languages: languages,
            tractRemoteSharePublisher: tractRemoteSharePublisher,
            tractRemoteShareSubscriber: tractRemoteShareSubscriber,
            localizationServices: localizationServices,
            analytics: analytics
        )
        
        self.navBarViewModel = navBarViewModel
        
        return navBarViewModel
    }
    
    func tractPageCardStateChanged(cardState: TractCardProperties.CardState) {
        
        if cardState == .open || cardState == .close {
            
            sendRemoteShareNavigationEventForPage(page: currentToolPage)
        }
    }
}

// MARK: - Tool Pages

extension ToolViewModel {
    
    private func reloadTool() {
        let languageTranslationModel: ToolLanguageTranslationModel = languageTranslationModels[currentLanguage]
        numberOfToolPages.accept(value: languageTranslationModel.manifest.pages.count)
    }
    
    private var currentLanguage: Int {
        return navBarViewModel?.selectedLanguage.value ?? 0
    }
    
    private var currentToolPage: Int {
        get {
            return currentPage.value.value
        }
        set(newValue) {
            currentPage.setValue(value: AnimatableValue(value: newValue, animated: false))
        }
    }
    
    func toolPageWillAppear(page: Int) -> ToolPageViewModel? {
        
        let languageTranslationModel: ToolLanguageTranslationModel = languageTranslationModels[currentLanguage]
        
        if let pageNode = languageTranslationModel.getToolPageNode(page: page) {
                      
            let initialPositions: ToolPageInitialPositions?
            
            if let lastToolPagePositionsForLanguageChange = self.lastToolPagePositionsForLanguageChange, lastToolPagePositionsForLanguageChange.page == page {
                initialPositions = lastToolPagePositionsForLanguageChange
                self.lastToolPagePositionsForLanguageChange = nil
            }
            else {
                initialPositions = nil
            }
            
            // TODO: Should primary manifest and primary language always be passed here? ~Levi
            // or should we pass parallel for parallel pages.
            
            let viewModel = ToolPageViewModel(
                delegate: self,
                pageNode: pageNode,
                manifest: languageTranslationModel.manifest,
                language: languageTranslationModel.language,
                translationsFileCache: translationsFileCache,
                mobileContentNodeParser: mobileContentNodeParser,
                mobileContentAnalytics: mobileContentAnalytics,
                mobileContentEvents: mobileContentEvents,
                fontService: fontService,
                followUpsService: followUpsService,
                localizationServices: localizationServices,
                page: page,
                initialPositions: initialPositions
            )
                        
            return viewModel
        }
        
        if page == lastToolPagePositionsForLanguageChange?.page {
            self.lastToolPagePositionsForLanguageChange = nil
        }
                
        return nil
    }
    
    func toolPageDidChange(page: Int) {
        
        self.currentToolPage = page
                
        sendRemoteShareNavigationEventForPage(page: page)
    }
    
    func toolPageDidAppear(page: Int) {
                      
        self.currentToolPage = page
                                
        analytics.pageViewedAnalytics.trackPageView(
            screenName: resource.abbreviation + "-" + String(page),
            siteSection: resource.abbreviation,
            siteSubSection: ""
        )
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
    
    func languageTapped(navBar: ToolNavBarViewModelType, language: LanguageModel) {
            
        reloadTool()
        
        sendRemoteShareNavigationEventForPage(page: currentToolPage)
    }
}

// MARK: - ToolPageViewModelDelegate

extension ToolViewModel: ToolPageViewModelDelegate {
    
    func toolPagePresented(viewModel: ToolPageViewModel, page: Int) {
        currentPage.accept(value: AnimatableValue(value: page, animated: true))
    }
    
    func toolPageTrainingTipTapped(trainingTipId: String, tipNode: TipNode) {
        
        let languageTranslationModel: ToolLanguageTranslationModel = languageTranslationModels[currentLanguage]
        
        flowDelegate?.navigate(step: .toolTrainingTipTappedFromTool(manifest: languageTranslationModel.manifest, trainingTipId: trainingTipId, tipNode: tipNode, language: languageTranslationModel.language))
    }
    
    func toolPageNextPageTapped() {
        
        gotoNextPage(animated: true)
    }
    
    func toolPageError(error: ContentEventError) {
        
        flowDelegate?.navigate(step: .toolDidEncounterErrorFromTool(error: error))
    }
}
