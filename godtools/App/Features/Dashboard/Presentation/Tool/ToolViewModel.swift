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
    private let resourceViewsService: ResourceViewsService
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let persistUserToolSettingsIfFavoriteToolUseCase: PersistUserToolSettingsIfFavoriteToolUseCase
    private let toolOpenedAnalytics: ToolOpenedAnalytics
    private let liveShareStream: String?
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var remoteShareIsActive: Bool = false
    private var shouldPersistNewToolSettings: Bool = false
    
    private weak var flowDelegate: FlowDelegate?
    
    let navBarAppearance: AppNavigationBarAppearance
    let languageFont: UIFont?
    let didSubscribeForRemoteSharePublishing: ObservableValue<Bool> = ObservableValue(value: false)
    
    @Published var hidesRemoteShareIsActive: Bool = true
        
    init(flowDelegate: FlowDelegate, renderer: MobileContentRenderer, tractRemoteSharePublisher: TractRemoteSharePublisher, tractRemoteShareSubscriber: TractRemoteShareSubscriber, resourceViewsService: ResourceViewsService, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, mobileContentEventAnalytics: MobileContentRendererEventAnalyticsTracking, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, translatedLanguageNameRepository: TranslatedLanguageNameRepository, toolOpenedAnalytics: ToolOpenedAnalytics, liveShareStream: String?, initialPage: MobileContentPagesPage?, trainingTipsEnabled: Bool, incrementUserCounterUseCase: IncrementUserCounterUseCase, persistUserToolSettingsIfFavoriteToolUseCase: PersistUserToolSettingsIfFavoriteToolUseCase, selectedLanguageIndex: Int?, shouldPersistNewToolSettings: Bool) {
        
        self.flowDelegate = flowDelegate
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        self.tractRemoteShareSubscriber = tractRemoteShareSubscriber
        self.resourceViewsService = resourceViewsService
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.persistUserToolSettingsIfFavoriteToolUseCase = persistUserToolSettingsIfFavoriteToolUseCase
        self.toolOpenedAnalytics = toolOpenedAnalytics
        self.liveShareStream = liveShareStream
        self.shouldPersistNewToolSettings = shouldPersistNewToolSettings
                
        let primaryManifest: Manifest = renderer.pageRenderers[0].manifest
        
        navBarAppearance = AppNavigationBarAppearance(
            backgroundColor: primaryManifest.navBarColor,
            controlColor: primaryManifest.navBarControlColor,
            titleFont: FontLibrary.systemUIFont(size: 17, weight: .semibold),
            titleColor: primaryManifest.navBarControlColor,
            isTranslucent: true
        )
        
        languageFont = FontLibrary.systemUIFont(size: 14, weight: .regular)
        
        super.init(renderer: renderer, initialPage: initialPage, resourcesRepository: resourcesRepository, translationsRepository: translationsRepository, mobileContentEventAnalytics: mobileContentEventAnalytics, getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, translatedLanguageNameRepository: translatedLanguageNameRepository, initialPageRenderingType: .visiblePages, trainingTipsEnabled: trainingTipsEnabled, incrementUserCounterUseCase: incrementUserCounterUseCase, selectedLanguageIndex: selectedLanguageIndex)
        
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
    
    private func trackLanguageTapped(tappedLanguage: LanguageDomainModel) {
        
        let primaryLanguage: LanguageDomainModel = languages[0]
        let parallelLanguage: LanguageDomainModel? = languages[safe: 1]
                
        let trackTappedLanguageData: [String: Any] = [
            AnalyticsConstants.Keys.contentLanguageSecondary: parallelLanguage?.localeIdentifier ?? "",
            AnalyticsConstants.ActionNames.parallelLanguageToggled: tappedLanguage.id == parallelLanguage?.id
        ]
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.parallelLanguageToggled,
            siteSection: analyticsSiteSection,
            siteSubSection: "",
            contentLanguage: primaryLanguage.localeIdentifier,
            contentLanguageSecondary: parallelLanguage?.localeIdentifier,
            url: nil,
            data: trackTappedLanguageData
        )
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
        
        let languages = ToolSettingsLanguages(
            primaryLanguageId: languages[0].id,
            parallelLanguageId: languages[safe: 1]?.id,
            selectedLanguageId: languages[selectedLanguageIndex].id
        )
        
        let toolSettingsObserver = ToolSettingsObserver(
            toolId: renderer.value.resource.id,
            languages: languages,
            pageNumber: currentRenderedPageNumber,
            trainingTipsEnabled: trainingTipsEnabled,
            tractRemoteSharePublisher: tractRemoteSharePublisher
        )

        toolSettingsObserver.$languages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (languages: ToolSettingsLanguages) in
                
                self?.setRendererPrimaryLanguage(
                    primaryLanguageId: languages.primaryLanguageId,
                    parallelLanguageId: languages.parallelLanguageId,
                    selectedLanguageId: languages.selectedLanguageId
                )
            }
            .store(in: &cancellables)
        
        toolSettingsObserver.$trainingTipsEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (trainingTipsEnabled: Bool) in
                
                self?.setTrainingTipsEnabled(enabled: trainingTipsEnabled)
            }
            .store(in: &cancellables)
        
        toolSettingsObserver.$languages
            .map { [weak self] (languages: ToolSettingsLanguages) in
                
                guard let self = self, self.shouldPersistNewToolSettings else {
                    return Just(false)
                        .eraseToAnyPublisher()
                }
                
                return self.persistUserToolSettingsIfFavoriteToolUseCase
                    .persistUserToolSettingsIfFavoriteToolPublisher(with: toolSettingsObserver.toolId, primaryLanguageId: languages.primaryLanguageId, parallelLanguageId: languages.parallelLanguageId)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                
            })
            .store(in: &cancellables)
        
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
    
    func languageTapped(index: Int, page: Int, pagePositions: ToolPagePositions) {
                
        let tappedLanguage: LanguageDomainModel = languages[index]
        
        if let pageRenderer = getPageRenderer(language: tappedLanguage) {
            setPageRenderer(pageRenderer: pageRenderer, navigationEvent: nil, pagePositions: pagePositions)
        }
        
        sendRemoteShareNavigationEvent(
            page: page,
            pagePositions: pagePositions
        )
        
        trackLanguageTapped(tappedLanguage: tappedLanguage)
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
