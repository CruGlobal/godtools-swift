//
//  ToolViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser
import Combine

class ToolViewModel: MobileContentPagesViewModel {
    
    private let tractRemoteSharePublisher: TractRemoteSharePublisher
    private let tractRemoteShareSubscriber: TractRemoteShareSubscriber
    private let fontService: FontService
    private let resourceViewsService: ResourceViewsService
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let toolOpenedAnalytics: ToolOpenedAnalytics
    private let liveShareStream: String?
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var remoteShareIsActive: Bool = false
    
    @Published private var languages: [LanguageDomainModel] = Array()
    
    private weak var flowDelegate: FlowDelegate?
    
    let navBarAppearance: AppNavigationBarAppearance
    let languageFont: UIFont?
    let didSubscribeForRemoteSharePublishing: ObservableValue<Bool> = ObservableValue(value: false)
    
    @Published var hidesRemoteShareIsActive: Bool = true
    @Published var languageNames: [String] = Array()
        
    init(flowDelegate: FlowDelegate, renderer: MobileContentRenderer, tractRemoteSharePublisher: TractRemoteSharePublisher, tractRemoteShareSubscriber: TractRemoteShareSubscriber, fontService: FontService, resourceViewsService: ResourceViewsService, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, mobileContentEventAnalytics: MobileContentRendererEventAnalyticsTracking, toolOpenedAnalytics: ToolOpenedAnalytics, liveShareStream: String?, initialPage: MobileContentPagesPage?, trainingTipsEnabled: Bool, incrementUserCounterUseCase: IncrementUserCounterUseCase, selectedLanguageIndex: Int?) {
        
        self.flowDelegate = flowDelegate
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        self.tractRemoteShareSubscriber = tractRemoteShareSubscriber
        self.fontService = fontService
        self.resourceViewsService = resourceViewsService
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.toolOpenedAnalytics = toolOpenedAnalytics
        self.liveShareStream = liveShareStream
                
        let primaryManifest: Manifest = renderer.pageRenderers[0].manifest
        
        navBarAppearance = AppNavigationBarAppearance(
            backgroundColor: primaryManifest.navBarColor,
            controlColor: primaryManifest.navBarControlColor,
            titleFont: fontService.getFont(size: 17, weight: .semibold),
            titleColor: primaryManifest.navBarControlColor,
            isTranslucent: true
        )
        
        languageFont = fontService.getFont(size: 14, weight: .regular)
        
        super.init(renderer: renderer, initialPage: initialPage, resourcesRepository: resourcesRepository, translationsRepository: translationsRepository, mobileContentEventAnalytics: mobileContentEventAnalytics, initialPageRenderingType: .visiblePages, trainingTipsEnabled: trainingTipsEnabled, incrementUserCounterUseCase: incrementUserCounterUseCase, selectedLanguageIndex: selectedLanguageIndex)
        
        setupBinding()
        
        $languages.eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (languages: [LanguageDomainModel]) in
                
                self?.languageNames = languages.map({$0.translatedName})
            }
            .store(in: &cancellables)
    }
    
    deinit {
                
        print("x deinit: \(type(of: self))")
        
        tractRemoteSharePublisher.didCreateNewSubscriberChannelIdForPublish.removeObserver(self)
        tractRemoteSharePublisher.endPublishingSession(disconnectSocket: true)
        
        tractRemoteShareSubscriber.navigationEventSignal.removeObserver(self)
        tractRemoteShareSubscriber.subscribedToChannelObserver.removeObserver(self)
        tractRemoteShareSubscriber.unsubscribe(disconnectSocket: true)
    }
    
    private func setupBinding() {
        
        tractRemoteSharePublisher.didCreateNewSubscriberChannelIdForPublish.addObserver(self) { [weak self] (channel: TractRemoteShareChannel) in
            DispatchQueue.main.async { [weak self] in
                self?.didSubscribeForRemoteSharePublishing.accept(value: true)
                self?.reloadRemoteShareIsActive()
            }
        }
        
        tractRemoteShareSubscriber.subscribedToChannelObserver.addObserver(self) { [weak self] (isSubscribed: Bool) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadRemoteShareIsActive()
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
    
    private func reloadRemoteShareIsActive() {
        
        let remoteShareIsActive: Bool = tractRemoteSharePublisher.isSubscriberChannelIdCreatedForPublish || tractRemoteShareSubscriber.isSubscribedToChannel
        
        self.remoteShareIsActive = remoteShareIsActive
        
        hidesRemoteShareIsActive = !remoteShareIsActive
    }
    
    private var analyticsScreenName: String {
        return resource.abbreviation
    }
    
    private var analyticsSiteSection: String {
        return resource.abbreviation
    }
        
    private var parallelLanguage: LanguageDomainModel? {
        if renderer.value.pageRenderers.count > 1 {
            return renderer.value.pageRenderers[1].language
        }
        return nil
    }
    
    private func getPageRenderer(language: LanguageDomainModel) -> MobileContentPageRenderer? {
        for pageRenderer in renderer.value.pageRenderers {
            if pageRenderer.language.localeIdentifier.lowercased() == language.localeIdentifier.lowercased() {
                return pageRenderer
            }
        }
        return nil
    }
    
    override func viewDidFinishLayout(window: UIViewController, safeArea: UIEdgeInsets) {
        
        super.viewDidFinishLayout(window: window, safeArea: safeArea)
        
        subscribeToLiveShareStreamIfNeeded()
        
        _ = resourceViewsService.postNewResourceView(resourceId: resource.id)
        
        toolOpenedAnalytics.trackFirstToolOpenedIfNeeded(resource: resource)
        toolOpenedAnalytics.trackToolOpened(resource: resource)
    }
    
    override func setRenderer(renderer: MobileContentRenderer, pageRendererIndex: Int?, navigationEvent: MobileContentPagesNavigationEvent?) {
                
        languages = renderer.pageRenderers.map({$0.language})
        
        super.setRenderer(renderer: renderer, pageRendererIndex: pageRendererIndex, navigationEvent: navigationEvent)
    }
}

// MARK: - Inputs

extension ToolViewModel {
    
    @objc func homeTapped() {
        
        let isScreenSharing: Bool = remoteShareIsActive
        
        flowDelegate?.navigate(step: .homeTappedFromTool(isScreenSharing: isScreenSharing))
    }
    
    @objc func backTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromTool)
    }
    
    @objc func toolSettingsTapped() {
        
        let toolData = ToolSettingsFlowToolData(
            renderer: renderer,
            currentPageRenderer: currentPageRenderer,
            tractRemoteSharePublisher: tractRemoteSharePublisher,
            pageNumber: currentRenderedPageNumber,
            trainingTipsEnabled: trainingTipsEnabled
        )
        
        flowDelegate?.navigate(step: .toolSettingsTappedFromTool(toolData: toolData))
    }
    
    func languageTapped(index: Int, page: Int, pagePositions: ToolPagePositions) {
                
        let language: LanguageDomainModel = languages[index]
        
        if let pageRenderer = getPageRenderer(language: language) {
            setPageRenderer(pageRenderer: pageRenderer, navigationEvent: nil, pagePositions: pagePositions)
        }
        
        sendRemoteShareNavigationEvent(
            page: page,
            pagePositions: pagePositions
        )
        
        let data: [String: String] = [
            AnalyticsConstants.ActionNames.parallelLanguageToggled: "",
            AnalyticsConstants.Keys.contentLanguageSecondary: language.localeIdentifier,
        ]
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.parallelLanguageToggled,
            siteSection: analyticsSiteSection,
            siteSubSection: "",
            contentLanguage: language.localeIdentifier,
            contentLanguageSecondary: nil,
            url: nil,
            data: data
        )
    }
    
    func subscribedForRemoteSharePublishing(page: Int, pagePositions: ToolPagePositions) {
     
        sendRemoteShareNavigationEvent(
            page: page,
            pagePositions: pagePositions
        )
    }
    
    func pageChanged(page: Int, pagePositions: ToolPagePositions) {
        
        sendRemoteShareNavigationEvent(
            page: page,
            pagePositions: pagePositions
        )
    }
    
    func cardChanged(page: Int, pagePositions: ToolPagePositions) {
        
        sendRemoteShareNavigationEvent(
            page: page,
            pagePositions: pagePositions
        )
    }
}

// MARK: - Remote Share Subscriber / Publisher

extension ToolViewModel {
    
    private func trackShareScreenOpened() {
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.shareScreenOpened,
            siteSection: analyticsSiteSection,
            siteSubSection: "",
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [
                AnalyticsConstants.Keys.shareScreenOpenedCountKey: 1
            ]
        )
    }
    
    private func subscribeToLiveShareStreamIfNeeded() {
        
        guard let channelId = liveShareStream, !channelId.isEmpty else {
            return
        }
                
        tractRemoteShareSubscriber.subscribe(channelId: channelId) { [weak self] (error: TractRemoteShareSubscriberError?) in
            DispatchQueue.main.async { [weak self] in
                self?.trackShareScreenOpened()
            }
        }
    }
    
    private func handleDidReceiveRemoteShareNavigationEvent(navigationEvent: TractRemoteShareNavigationEvent, animated: Bool) {
        
        let attributes = navigationEvent.message?.data?.attributes
        
        let page: Int? = attributes?.page
        let cardPosition: Int? = attributes?.card
        
        let navBarLanguages: [LanguageDomainModel] = languages
        let currentNavBarLanguage: LanguageDomainModel = languages[selectedLanguageIndex]
        var remoteShareLanguage: LanguageDomainModel = currentNavBarLanguage
        var remoteShareLanguageIndex: Int?
        
        if let locale = attributes?.locale, !locale.isEmpty {
            
            for index in 0 ..< navBarLanguages.count {
                
                let language: LanguageDomainModel = navBarLanguages[index]

                if locale.lowercased() == language.localeIdentifier.lowercased() {
                    remoteShareLanguage = language
                    remoteShareLanguageIndex = index
                    break
                }
            }
        }
        
        let navBarLanguageChanged: Bool = remoteShareLanguage.id != currentNavBarLanguage.id
        let pagePositions: MobileContentViewPositionState? = ToolPagePositions(cardPosition: cardPosition)
        
        let navigationEvent = MobileContentPagesNavigationEvent(
            pageNavigation: PageNavigationCollectionViewNavigationModel(
                navigationDirection: nil,
                page: page ?? super.currentRenderedPageNumber,
                animated: animated,
                reloadCollectionViewDataNeeded: navBarLanguageChanged,
                insertPages: nil
            ),
            pagePositions: pagePositions
        )
                        
        if let remoteShareLanguageIndex = remoteShareLanguageIndex, navBarLanguageChanged {
            
            super.setPageRenderer(pageRenderer: renderer.value.pageRenderers[remoteShareLanguageIndex], navigationEvent: nil, pagePositions: pagePositions)
        }
        else {
            
            super.sendPageNavigationEvent(navigationEvent: navigationEvent)
        }
    }
    
    private func sendRemoteShareNavigationEvent(page: Int, pagePositions: ToolPagePositions) {
        
        guard tractRemoteSharePublisher.isSubscriberChannelIdCreatedForPublish else {
            return
        }
        
        let localeId: String = languages[selectedLanguageIndex].localeIdentifier
                
        let event = TractRemoteSharePublisherNavigationEvent(
            card: pagePositions.cardPosition,
            locale: localeId,
            page: page,
            tool: resource.abbreviation
        )
        
        tractRemoteSharePublisher.sendNavigationEvent(event: event)
    }
}
