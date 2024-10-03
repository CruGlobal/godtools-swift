//
//  TractViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser
import Combine

class TractViewModel: MobileContentPagesViewModel {
    
    private let tractRemoteSharePublisher: TractRemoteSharePublisher
    private let tractRemoteShareSubscriber: TractRemoteShareSubscriber
    private let resourceViewsService: ResourceViewsService
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let persistUserToolLanguageSettingsUseCase: PersistUserToolLanguageSettingsUseCase
    private let toolOpenedAnalytics: ToolOpenedAnalytics
    private let liveShareStream: String?
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var remoteShareIsActive: Bool = false
    private var shouldPersistToolSettings: Bool = false
    
    private weak var flowDelegate: FlowDelegate?
    
    let navBarAppearance: AppNavigationBarAppearance
    let languageFont: UIFont?
    let didSubscribeForRemoteSharePublishing: ObservableValue<Bool> = ObservableValue(value: false)
    
    @Published var hidesRemoteShareIsActive: Bool = true
        
    init(flowDelegate: FlowDelegate, renderer: MobileContentRenderer, tractRemoteSharePublisher: TractRemoteSharePublisher, tractRemoteShareSubscriber: TractRemoteShareSubscriber, resourceViewsService: ResourceViewsService, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, mobileContentEventAnalytics: MobileContentRendererEventAnalyticsTracking, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getTranslatedLanguageName: GetTranslatedLanguageName, toolOpenedAnalytics: ToolOpenedAnalytics, liveShareStream: String?, initialPage: MobileContentPagesPage?, trainingTipsEnabled: Bool, incrementUserCounterUseCase: IncrementUserCounterUseCase, selectedLanguageIndex: Int?, persistUserToolLanguageSettingsUseCase: PersistUserToolLanguageSettingsUseCase, shouldPersistToolSettings: Bool) {
        
        self.flowDelegate = flowDelegate
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        self.tractRemoteShareSubscriber = tractRemoteShareSubscriber
        self.resourceViewsService = resourceViewsService
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.toolOpenedAnalytics = toolOpenedAnalytics
        self.liveShareStream = liveShareStream
        self.persistUserToolLanguageSettingsUseCase = persistUserToolLanguageSettingsUseCase
        self.shouldPersistToolSettings = shouldPersistToolSettings
                
        let primaryManifest: Manifest = renderer.pageRenderers[0].manifest
        
        navBarAppearance = AppNavigationBarAppearance(
            backgroundColor: primaryManifest.navBarColor,
            controlColor: primaryManifest.navBarControlColor,
            titleFont: FontLibrary.systemUIFont(size: 17, weight: .semibold),
            titleColor: primaryManifest.navBarControlColor,
            isTranslucent: true
        )
        
        languageFont = FontLibrary.systemUIFont(size: 14, weight: .regular)
        
        super.init(renderer: renderer, initialPage: initialPage, resourcesRepository: resourcesRepository, translationsRepository: translationsRepository, mobileContentEventAnalytics: mobileContentEventAnalytics, getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, getTranslatedLanguageName: getTranslatedLanguageName, initialPageRenderingType: .visiblePages, trainingTipsEnabled: trainingTipsEnabled, incrementUserCounterUseCase: incrementUserCounterUseCase, selectedLanguageIndex: selectedLanguageIndex)
        
        setupBinding()
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
        
    private var parallelLanguage: LanguageModel? {
        if renderer.value.pageRenderers.count > 1 {
            return renderer.value.pageRenderers[1].language
        }
        return nil
    }
    
    private func getPageRenderer(language: LanguageModel) -> MobileContentPageRenderer? {
        
        let languageLocaleId: String = language.localeId.lowercased()
        
        for pageRenderer in renderer.value.pageRenderers where pageRenderer.language.localeId.lowercased() == languageLocaleId {
            return pageRenderer
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
    
    private func trackLanguageTapped(tappedLanguage: LanguageModel) {
        
        let primaryLanguage: LanguageModel = languages[0]
        let parallelLanguage: LanguageModel? = languages[safe: 1]
                
        let trackTappedLanguageData: [String: Any] = [
            AnalyticsConstants.Keys.contentLanguageSecondary: parallelLanguage?.localeId ?? "",
            AnalyticsConstants.ActionNames.parallelLanguageToggled: tappedLanguage.id == parallelLanguage?.id
        ]
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.parallelLanguageToggled,
            siteSection: analyticsSiteSection,
            siteSubSection: "",
            contentLanguage: primaryLanguage.localeId,
            contentLanguageSecondary: parallelLanguage?.localeId,
            url: nil,
            data: trackTappedLanguageData
        )
    }
    
    override func createToolSettingsObserver(with toolSettingsLanguages: ToolSettingsLanguages) -> TractToolSettingsObserver {
        let tractToolSettingsObserver = TractToolSettingsObserver(
            toolId: renderer.value.resource.id,
            languages: toolSettingsLanguages,
            pageNumber: currentRenderedPageNumber,
            trainingTipsEnabled: trainingTipsEnabled,
            tractRemoteSharePublisher: tractRemoteSharePublisher
        )
        
        return tractToolSettingsObserver
    }
    
    override func attachObserversForToolSettings(_ toolSettingsObserver: ToolSettingsObserver) -> ToolSettingsObserver {
        
        let attachedToolSettingsObserver = super.attachObserversForToolSettings(toolSettingsObserver)
        
        if shouldPersistToolSettings {
            
            attachedToolSettingsObserver.$languages
                .map { [weak self] (languages: ToolSettingsLanguages) in
                    
                    guard let self = self else {
                        return Just(false)
                            .eraseToAnyPublisher()
                    }
                    
                    return self.persistUserToolLanguageSettingsUseCase
                        .persistUserToolSettingsPublisher(
                            with: renderer.value.resource.id,
                            primaryLanguageId: languages.primaryLanguageId,
                            parallelLanguageId: languages.parallelLanguageId
                        )
                }
                .switchToLatest()
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { _ in
                    
                })
                .store(in: &cancellables)
        }
        
        return attachedToolSettingsObserver
    }
}

// MARK: - Inputs

extension TractViewModel {
    
    @objc func homeTapped() {
        
        let isScreenSharing: Bool = remoteShareIsActive
        
        flowDelegate?.navigate(step: .homeTappedFromTool(isScreenSharing: isScreenSharing))
    }
    
    @objc func backTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromTool)
    }
    
    @objc func toolSettingsTapped() {
        
        let toolSettingsObserver = setUpToolSettingsObserver()
        
        trackActionAnalyticsUseCase
            .trackAction(
                screenName: analyticsScreenName,
                actionName: "Tool Settings",
                siteSection: analyticsSiteSection,
                siteSubSection: "",
                contentLanguage: nil,
                contentLanguageSecondary: nil,
                url: nil,
                data: [ToolAnalyticsActionNames.shared.ACTION_SETTINGS: 1]
            )
        
        flowDelegate?.navigate(step: .toolSettingsTappedFromTool(toolSettingsObserver: toolSettingsObserver))
    }
    
    func languageTapped(index: Int, page: Int, pagePositions: TractPagePositions) {
                
        let tappedLanguage: LanguageModel = languages[index]
        
        if let pageRenderer = getPageRenderer(language: tappedLanguage) {
            setPageRenderer(pageRenderer: pageRenderer, navigationEvent: nil, pagePositions: pagePositions)
        }
        
        sendRemoteShareNavigationEvent(
            page: page,
            pagePositions: pagePositions
        )
        
        if let toolSettingsObserver = toolSettingsObserver {
            
            let languages = toolSettingsObserver.languages
            self.toolSettingsObserver?.languages = ToolSettingsLanguages(
                primaryLanguageId: languages.primaryLanguageId,
                parallelLanguageId: languages.parallelLanguageId,
                selectedLanguageId: tappedLanguage.id
            )
        } else {
            _ = setUpToolSettingsObserver()
        }
        
        trackLanguageTapped(tappedLanguage: tappedLanguage)
    }
    
    func subscribedForRemoteSharePublishing(page: Int, pagePositions: TractPagePositions) {
     
        sendRemoteShareNavigationEvent(
            page: page,
            pagePositions: pagePositions
        )
    }
    
    func pageChanged(page: Int, pagePositions: TractPagePositions) {
        
        sendRemoteShareNavigationEvent(
            page: page,
            pagePositions: pagePositions
        )
    }
    
    func cardChanged(page: Int, pagePositions: TractPagePositions) {
        
        sendRemoteShareNavigationEvent(
            page: page,
            pagePositions: pagePositions
        )
    }
}

// MARK: - Remote Share Subscriber / Publisher

extension TractViewModel {
    
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
        
        let navBarLanguages: [LanguageModel] = languages
        let currentNavBarLanguage: LanguageModel = languages[selectedLanguageIndex]
        var remoteShareLanguage: LanguageModel = currentNavBarLanguage
        var remoteShareLanguageIndex: Int?
        
        if let locale = attributes?.locale, !locale.isEmpty {
            
            for index in 0 ..< navBarLanguages.count {
                
                let language: LanguageModel = navBarLanguages[index]

                if locale.lowercased() == language.localeId.lowercased() {
                    remoteShareLanguage = language
                    remoteShareLanguageIndex = index
                    break
                }
            }
        }
        
        let navBarLanguageChanged: Bool = remoteShareLanguage.id != currentNavBarLanguage.id
        let pagePositions: MobileContentViewPositionState? = TractPagePositions(cardPosition: cardPosition)
        
        let navigationEvent = MobileContentPagesNavigationEvent(
            pageNavigation: PageNavigationCollectionViewNavigationModel(
                navigationDirection: nil,
                page: page ?? super.currentRenderedPageNumber,
                animated: animated,
                reloadCollectionViewDataNeeded: navBarLanguageChanged,
                insertPages: nil,
                deletePages: nil
            ),
            setPages: nil,
            pagePositions: pagePositions
        )
                        
        if let remoteShareLanguageIndex = remoteShareLanguageIndex, navBarLanguageChanged {
            
            super.setPageRenderer(pageRenderer: renderer.value.pageRenderers[remoteShareLanguageIndex], navigationEvent: nil, pagePositions: pagePositions)
        }
        else {
            
            super.sendPageNavigationEvent(navigationEvent: navigationEvent)
        }
    }
    
    private func sendRemoteShareNavigationEvent(page: Int, pagePositions: TractPagePositions) {
        
        guard tractRemoteSharePublisher.isSubscriberChannelIdCreatedForPublish else {
            return
        }
        
        let localeId: String = languages[selectedLanguageIndex].localeId
                
        let event = TractRemoteSharePublisherNavigationEvent(
            card: pagePositions.cardPosition,
            locale: localeId,
            page: page,
            tool: resource.abbreviation
        )
        
        tractRemoteSharePublisher.sendNavigationEvent(event: event)
    }
}
