//
//  ToolViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolViewModel: MobileContentPagesViewModel {
    
    private let resource: ResourceModel
    private let primaryLanguage: LanguageModel
    private let toolPageEvents: ToolPageEvents
    private let tractRemoteSharePublisher: TractRemoteSharePublisher
    private let tractRemoteShareSubscriber: TractRemoteShareSubscriber
    private let localizationServices: LocalizationServices
    private let fontService: FontService
    private let viewsService: ViewsService
    private let analytics: AnalyticsContainer
    private let toolOpenedAnalytics: ToolOpenedAnalytics
    
    let navBarViewModel: ToolNavBarViewModel
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, renderers: [MobileContentRenderer], resource: ResourceModel, primaryLanguage: LanguageModel, toolPageEvents: ToolPageEvents, tractRemoteSharePublisher: TractRemoteSharePublisher, tractRemoteShareSubscriber: TractRemoteShareSubscriber, localizationServices: LocalizationServices, fontService: FontService, viewsService: ViewsService, analytics: AnalyticsContainer, toolOpenedAnalytics: ToolOpenedAnalytics, liveShareStream: String?, trainingTipsEnabled: Bool, page: Int?) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.primaryLanguage = primaryLanguage
        self.toolPageEvents = toolPageEvents
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        self.tractRemoteShareSubscriber = tractRemoteShareSubscriber
        self.localizationServices = localizationServices
        self.fontService = fontService
        self.viewsService = viewsService
        self.analytics = analytics
        self.toolOpenedAnalytics = toolOpenedAnalytics
        
        let primaryManifest: MobileContentXmlManifest = renderers.first!.manifest
        let languages: [LanguageModel] = renderers.map({$0.language})
        
        navBarViewModel = ToolNavBarViewModel(
            resource: resource,
            manifestAttributes: primaryManifest.attributes,
            languages: languages,
            tractRemoteSharePublisher: tractRemoteSharePublisher,
            tractRemoteShareSubscriber: tractRemoteShareSubscriber,
            localizationServices: localizationServices,
            fontService: fontService,
            analytics: analytics,
            hidesShareButton: trainingTipsEnabled
        )
        
        super.init(flowDelegate: flowDelegate, renderers: renderers, primaryLanguage: primaryLanguage, page: page)
        
        setupBinding()
        
        subscribeToLiveShareStreamIfNeeded(liveShareStream: liveShareStream)
    }
    
    required init(flowDelegate: FlowDelegate, renderers: [MobileContentRenderer], primaryLanguage: LanguageModel, page: Int?) {
        fatalError("init(flowDelegate:renderers:primaryLanguage:page:) has not been implemented")
    }
    
    deinit {
        
        toolPageEvents.didTapCallToActionNextButtonSignal.removeObserver(self)
        
        tractRemoteSharePublisher.didCreateNewSubscriberChannelIdForPublish.removeObserver(self)
        tractRemoteSharePublisher.endPublishingSession(disconnectSocket: true)
        
        tractRemoteShareSubscriber.navigationEventSignal.removeObserver(self)
        tractRemoteShareSubscriber.unsubscribe(disconnectSocket: true)
    }
    
    private func setupBinding() {
        
        toolPageEvents.didTapCallToActionNextButtonSignal.addObserver(self) { [weak self] in
            self?.gotoNextPage(animated: true)
        }
        
        tractRemoteSharePublisher.didCreateNewSubscriberChannelIdForPublish.addObserver(self) { [weak self] (channel: TractRemoteShareChannel) in
            DispatchQueue.main.async { [weak self] in
                if let currentPage = self?.getCurrentPageValue() {
                    self?.sendRemoteShareNavigationEventForPage(page: currentPage)
                }
            }
        }
        
        var isFirstRemoteShareNavigationEvent: Bool = true
        
        tractRemoteShareSubscriber.navigationEventSignal.addObserver(self) { [weak self] (navigationEvent: TractRemoteShareNavigationEvent) in
            DispatchQueue.main.async { [weak self] in
                let animated: Bool = !isFirstRemoteShareNavigationEvent
                self?.handleDidReceiveRemoteShareNavigationEvent(navigationEvent: navigationEvent, animated: animated)
                isFirstRemoteShareNavigationEvent = false
            }
        }
    }
    
    private var parallelLanguage: LanguageModel? {
        if renderers.count > 1 {
            return renderers[1].language
        }
        return nil
    }
    
    override func viewDidFinishLayout(window: UIViewController, safeArea: UIEdgeInsets) {
        
        super.viewDidFinishLayout(window: window, safeArea: safeArea)
        
        _ = viewsService.postNewResourceView(resourceId: resource.id)
        
        toolOpenedAnalytics.trackFirstToolOpenedIfNeeded()
        toolOpenedAnalytics.trackToolOpened()
    }
    
    override func pageDidChange(page: Int) {
        super.pageDidChange(page: page)
        
        sendRemoteShareNavigationEventForPage(page: page)
    }
}

// MARK: - Remote Share Subscriber / Publisher

extension ToolViewModel {
    
    private func trackShareScreenOpened() {
        
        analytics.trackActionAnalytics.trackAction(
            screenName: nil,
            actionName: AnalyticsConstants.Values.shareScreenOpen,
            data: [
                AnalyticsConstants.ActionNames.shareScreenOpenCountKey: 1
            ]
        )
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
    
    private func handleDidReceiveRemoteShareNavigationEvent(navigationEvent: TractRemoteShareNavigationEvent, animated: Bool = true) {
        
        let attributes = navigationEvent.message?.data?.attributes
        
        var navigateToLanguage: Int?
        let navigateToPage: Int? = attributes?.page
        let navigateToCard: Int? = attributes?.card
        
        let languages: [LanguageModel] = navBarViewModel.languages
        
        if let locale = attributes?.locale, !locale.isEmpty {
            for index in 0 ..< languages.count {
                if locale.lowercased() == languages[index].code.lowercased() {
                    navigateToLanguage = index
                }
            }
        }
        
        /*
        setToolPage(
            language: navigateToLanguage,
            page: navigateToPage ?? currentToolPage,
            card: navigateToCard,
            animated: animated
        )*/
    }
    
    private func sendRemoteShareNavigationEventForPage(page: Int) {
        
        guard tractRemoteSharePublisher.isSubscriberChannelIdCreatedForPublish else {
            return
        }
        
        /*
        let currentToolPagePositions: ToolPageInitialPositions? = currentPagesViewModelsCache.getPage(page: page)?.getCurrentPositions()
        let language: LanguageModel = languages[currentToolLanguage]
        
        let event = TractRemoteSharePublisherNavigationEvent(
            card: currentToolPagePositions?.card,
            locale: language.code,
            page: page,
            tool: resource.abbreviation
        )
        
        tractRemoteSharePublisher.sendNavigationEvent(event: event)*/
    }
}

// MARK: - Nav Bar

extension ToolViewModel {
    
    func navHomeTapped(remoteShareIsActive: Bool) {
        flowDelegate?.navigate(step: .homeTappedFromTool(isScreenSharing: remoteShareIsActive))
    }
    
    func navShareTapped(selectedLanguage: LanguageModel) {

        let pageNumber: Int = currentPage.value.value
        
        flowDelegate?.navigate(step: .shareMenuTappedFromTool(tractRemoteShareSubscriber: tractRemoteShareSubscriber, tractRemoteSharePublisher: tractRemoteSharePublisher, resource: resource, selectedLanguage: selectedLanguage, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, pageNumber: pageNumber))
    }
    
    func navLanguageChanged() {
          
        let navBarLanguage: LanguageModel = navBarViewModel.language
        
        for renderer in renderers {
            if renderer.language.code == navBarLanguage.code {
                setRenderer(renderer: renderer)
                break
            }
        }
        
        sendRemoteShareNavigationEventForPage(page: getCurrentPageValue())
    }
}

/*
class ToolViewModel: MobileContentPagesViewModel {
    
    
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, primaryLanguage: LanguageModel, parallelLanguage: LanguageModel?, primaryTranslationManifestData: TranslationManifestData, parallelTranslationManifestData: TranslationManifestData?, mobileContentNodeParser: MobileContentXmlNodeParser, mobileContentAnalytics: MobileContentAnalytics, mobileContentEvents: MobileContentEvents, translationsFileCache: TranslationsFileCache, languageSettingsService: LanguageSettingsService, fontService: FontService, tractRemoteSharePublisher: TractRemoteSharePublisher, tractRemoteShareSubscriber: TractRemoteShareSubscriber, isNewUserService: IsNewUserService, cardJumpService: CardJumpService, followUpsService: FollowUpsService, viewsService: ViewsService, localizationServices: LocalizationServices, analytics: AnalyticsContainer, toolOpenedAnalytics: ToolOpenedAnalytics, liveShareStream: String?, viewedTrainingTips: ViewedTrainingTipsService, trainingTipsEnabled: Bool, page: Int?) {
                
                
        let startingToolPage: Int = page ?? 0
            
        forceToolRefresh(language: 0, page: startingToolPage, card: nil)
                
        subscribeToLiveShareStreamIfNeeded(liveShareStream: liveShareStream)
        
        for toolLanguageTranslationModel in languageTranslationModels {
            toolLanguageTranslationModel.setToolPageListenersNotifierDelegate(delegate: self)
        }
    }

}

*/

/*

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
        
        /*
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
        }*/
    }
    
}

// MARK: - ToolPageViewModelTypeDelegate

extension ToolViewModel: ToolPageViewModelTypeDelegate {
        
    func toolPageTrainingTipTapped(viewModel: ToolPageViewModelType, page: Int, trainingTipId: String, tipNode: TipNode) {

        guard page == self.currentToolPage else {
            return
        }
                
        let languageTranslationModel: ToolLanguageTranslationModel = languageTranslationModels[currentToolLanguage]
        
        let toolPage: Int = currentPage.value.value
        
        flowDelegate?.navigate(step: .toolTrainingTipTappedFromTool(resource: resource, manifest: languageTranslationModel.manifest, trainingTipId: trainingTipId, tipNode: tipNode, language: languageTranslationModel.language, primaryLanguage: primaryLanguageTranslationModel.language, toolPage: toolPage))
    }
    
    func toolPageCardChanged(viewModel: ToolPageViewModelType, page: Int, cardPosition: Int?) {
        
        guard page == self.currentToolPage else {
            return
        }
        
        sendRemoteShareNavigationEventForPage(page: currentToolPage)
    }
}
*/
