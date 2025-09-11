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

class TractViewModel: MobileContentRendererViewModel {
    
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    
    static let isLiveShareStreamingKey: String = "TractViewModel.isLiveShareStreamKey"
    
    private let tractRemoteSharePublisher: TractRemoteSharePublisher
    private let tractRemoteShareSubscriber: TractRemoteShareSubscriber
    private let languagesRepository: LanguagesRepository
    private let resourceViewsService: ResourceViewsService
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let liveShareStream: String?
    private let persistToolLanguageSettings: PersistToolLanguageSettingsInterface?
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var remoteShareIsActive: Bool = false
    
    private weak var flowDelegate: FlowDelegate?
    
    let navBarAppearance: AppNavigationBarAppearance
    let languageFont: UIFont?
    let didSubscribeForRemoteSharePublishing: ObservableValue<Bool> = ObservableValue(value: false)
    
    @Published private(set) var toolSettingsDidClose: Void?
    @Published private(set) var hidesRemoteShareIsActive: Bool = true
        
    init(flowDelegate: FlowDelegate, renderer: MobileContentRenderer, tractRemoteSharePublisher: TractRemoteSharePublisher, tractRemoteShareSubscriber: TractRemoteShareSubscriber, languagesRepository: LanguagesRepository, resourceViewsService: ResourceViewsService, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, mobileContentEventAnalytics: MobileContentRendererEventAnalyticsTracking, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getTranslatedLanguageName: GetTranslatedLanguageName, liveShareStream: String?, initialPage: MobileContentRendererInitialPage?, initialPageSubIndex: Int?, trainingTipsEnabled: Bool, incrementUserCounterUseCase: IncrementUserCounterUseCase, selectedLanguageIndex: Int?, persistToolLanguageSettings: PersistToolLanguageSettingsInterface?) {
        
        self.flowDelegate = flowDelegate
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        self.tractRemoteShareSubscriber = tractRemoteShareSubscriber
        self.languagesRepository = languagesRepository
        self.resourceViewsService = resourceViewsService
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.liveShareStream = liveShareStream
        self.persistToolLanguageSettings = persistToolLanguageSettings
                
        let primaryManifest: Manifest = renderer.pageRenderers[0].manifest
        
        navBarAppearance = AppNavigationBarAppearance(
            backgroundColor: primaryManifest.navBarColor.toUIColor(),
            controlColor: primaryManifest.navBarControlColor.toUIColor(),
            titleFont: FontLibrary.systemUIFont(size: 17, weight: .semibold),
            titleColor: primaryManifest.navBarControlColor.toUIColor(),
            isTranslucent: true
        )
        
        languageFont = FontLibrary.systemUIFont(size: 14, weight: .regular)
        
        super.init(renderer: renderer, initialPage: initialPage, initialPageConfig: nil, initialPageSubIndex: initialPageSubIndex, resourcesRepository: resourcesRepository, translationsRepository: translationsRepository, mobileContentEventAnalytics: mobileContentEventAnalytics, getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, getTranslatedLanguageName: getTranslatedLanguageName, trainingTipsEnabled: trainingTipsEnabled, incrementUserCounterUseCase: incrementUserCounterUseCase, selectedLanguageIndex: selectedLanguageIndex)
               
        if let remoteSharePublisherChannel = tractRemoteSharePublisher.tractRemoteShareChannel {
            
            handleRemoteSharePublisherChannelCreated(channel: remoteSharePublisherChannel)
        }
        else {
            
            tractRemoteSharePublisher
                .didCreateChannelPublisher
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    
                } receiveValue: { [weak self] (channel: WebSocketChannel) in
                    
                    self?.handleRemoteSharePublisherChannelCreated(channel: channel)
                }
                .store(in: &cancellables)
        }

        var isFirstRemoteShareNavigationEvent: Bool = true
        tractRemoteShareSubscriber
            .navigationEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (event: TractRemoteShareNavigationEvent) in
                
                let animated: Bool = !isFirstRemoteShareNavigationEvent
                self?.handleDidReceiveRemoteShareNavigationEvent(remoteShareNavigationEvent: event, animated: animated)
                isFirstRemoteShareNavigationEvent = false
            }
            .store(in: &cancellables)
    }
    
    deinit {
                
        print("x deinit: \(type(of: self))")
        
        tractRemoteSharePublisher.endPublishingSession(disconnectSocket: true)
        
        tractRemoteShareSubscriber.unsubscribe(disconnectSocket: true)
    }
    
    private var isLiveStreaming: Bool {
        
        let liveShareStreamChannelIdIsEmpty: Bool = (liveShareStream?.isEmpty) ?? true
        
        return tractRemoteSharePublisher.webSocketIsConnected || tractRemoteShareSubscriber.webSocketIsConnected || !liveShareStreamChannelIdIsEmpty
    }
    
    private func handleRemoteSharePublisherChannelCreated(channel: WebSocketChannel) {
        didSubscribeForRemoteSharePublishing.accept(value: true)
        reloadRemoteShareIsActive()
    }
    
    private func reloadRemoteShareIsActive() {
        
        let remoteShareIsActive: Bool = tractRemoteSharePublisher.isSubscriberChannelCreatedForPublish || tractRemoteShareSubscriber.isSubscribedToChannel
        
        self.remoteShareIsActive = remoteShareIsActive
        
        hidesRemoteShareIsActive = !remoteShareIsActive
    }
    
    private var analyticsScreenName: String {
        return resource.abbreviation
    }
    
    private var analyticsSiteSection: String {
        return resource.abbreviation
    }
        
    private var parallelLanguage: LanguageDataModel? {
        if renderer.value.pageRenderers.count > 1 {
            return renderer.value.pageRenderers[1].language
        }
        return nil
    }
    
    private func getPageRenderer(language: LanguageDataModel) -> MobileContentPageRenderer? {
        
        let languageLocaleId: String = language.localeId.lowercased()
        
        for pageRenderer in renderer.value.pageRenderers where pageRenderer.language.localeId.lowercased() == languageLocaleId {
            return pageRenderer
        }
        
        return nil
    }
    
    override func viewDidFinishLayout(window: UIViewController, safeArea: UIEdgeInsets) {
        
        super.viewDidFinishLayout(window: window, safeArea: safeArea)
        
        subscribeToLiveShareStreamIfNeeded()
        
        resourceViewsService
            .postNewResourceViewPublisher(resourceId: resource.id, requestPriority: .medium)
            .sink { _ in
                
            } receiveValue: { _ in
                
            }
            .store(in: &Self.backgroundCancellables)
    }
    
    private func trackLanguageTapped(tappedLanguage: LanguageDataModel) {
        
        let primaryLanguage: LanguageDataModel = languages[0]
        let parallelLanguage: LanguageDataModel? = languages[safe: 1]
                
        let trackTappedLanguageData: [String: Any] = [
            AnalyticsConstants.Keys.contentLanguageSecondary: parallelLanguage?.localeId ?? "",
            AnalyticsConstants.ActionNames.parallelLanguageToggled: tappedLanguage.id == parallelLanguage?.id
        ]
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.parallelLanguageToggled,
            siteSection: analyticsSiteSection,
            siteSubSection: "",
            appLanguage: nil,
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
            pageNumber: currentPageNumber,
            trainingTipsEnabled: trainingTipsEnabled,
            tractRemoteSharePublisher: tractRemoteSharePublisher
        )
        
        return tractToolSettingsObserver
    }
    
    override func attachObserversForToolSettings(_ toolSettingsObserver: ToolSettingsObserver) -> ToolSettingsObserver {
        
        let attachedToolSettingsObserver = super.attachObserversForToolSettings(toolSettingsObserver)
        
        if let persistToolLanguageSettings = persistToolLanguageSettings {
            
            attachedToolSettingsObserver.$languages
                .map { [weak self] (languages: ToolSettingsLanguages) in
                    
                    guard let self = self else {
                        return Just(false)
                            .eraseToAnyPublisher()
                    }
                    
                    return persistToolLanguageSettings
                        .persistToolLanguageSettingsPublisher(
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
    
    override func configureRendererPageContextUserInfo(userInfo: inout [String: Any], page: Int) {
        
        userInfo[TractViewModel.isLiveShareStreamingKey] = isLiveStreaming
        
        super.configureRendererPageContextUserInfo(userInfo: &userInfo, page: page)
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
        
        let toolSettingsDidCloseClosure = { [weak self] () -> Void in
            self?.toolSettingsDidClose = ()
        }
        
        let toolSettingsObserver = setUpToolSettingsObserver()
        
        trackActionAnalyticsUseCase
            .trackAction(
                screenName: analyticsScreenName,
                actionName: "Tool Settings",
                siteSection: analyticsSiteSection,
                siteSubSection: "",
                appLanguage: nil,
                contentLanguage: nil,
                contentLanguageSecondary: nil,
                url: nil,
                data: [ToolAnalyticsActionNames.shared.ACTION_SETTINGS: 1]
            )
        
        flowDelegate?.navigate(step: .toolSettingsTappedFromTool(toolSettingsObserver: toolSettingsObserver, toolSettingsDidCloseClosure: toolSettingsDidCloseClosure))
    }
    
    func languageTapped(index: Int, page: Int, pagePositions: TractPagePositions) {
                
        let tappedLanguage: LanguageDataModel = languages[index]
        
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
            appLanguage: nil,
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [
                AnalyticsConstants.Keys.shareScreenOpenedCountKey: 1
            ]
        )
    }
    
    private func subscribeToLiveShareStreamIfNeeded() {
        
        guard let channelId = liveShareStream, let channel = WebSocketChannel(id: channelId) else {
            return
        }
        
        tractRemoteShareSubscriber
            .didSubscribePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (channel: WebSocketChannel) in
                
                self?.trackShareScreenOpened()
                self?.reloadRemoteShareIsActive()
            }
            .store(in: &cancellables)
        
        tractRemoteShareSubscriber
            .subscribe(channel: channel)
    }
    
    private func handleDidReceiveRemoteShareNavigationEvent(remoteShareNavigationEvent: TractRemoteShareNavigationEvent, animated: Bool) {
        
        let attributes = remoteShareNavigationEvent.message?.data?.attributes
                
        let remoteShareSelectedLocale: String? = attributes?.locale
        let remoteShareNavBarLocales: [String] = getRemoteShareNavBarLocales(remoteShareNavigationEvent: remoteShareNavigationEvent)
        
        let navBarSelectedLocale: String? = languages[safe: selectedLanguageIndex]?.code
        let navBarLocales: [String] = languages.map { $0.code }
        
        let navBarLanguagesAreTheSame: Bool = navBarLocales.count == remoteShareNavBarLocales.count && navBarLocales == remoteShareNavBarLocales
        let selectedLocaleChanged: Bool
        
        if let navBarSelectedLocale = navBarSelectedLocale, !navBarSelectedLocale.isEmpty, let remoteShareSelectedLocale = remoteShareSelectedLocale, !remoteShareSelectedLocale.isEmpty {
            selectedLocaleChanged = navBarSelectedLocale != remoteShareSelectedLocale
        }
        else {
            selectedLocaleChanged = false
        }
                       
        if selectedLocaleChanged && navBarLanguagesAreTheSame,
           let index = languages.firstIndex(where: { $0.code == remoteShareSelectedLocale }),
           let selectedLocalePageRenderer = renderer.value.pageRenderers[safe: index] {
            
            super.setPageRenderer(
                pageRenderer: selectedLocalePageRenderer,
                navigationEvent: getPagesNavigationEventForRemoteShareNavigationEvent(
                    remoteShareNavigationEvent: remoteShareNavigationEvent,
                    animated: animated,
                    reloadCollectionViewDataNeeded: true
                ),
                pagePositions: getPagePositionsForRemoteShareNavigationEvent(
                    remoteShareNavigationEvent: remoteShareNavigationEvent
                )
            )
        }
        else if selectedLocaleChanged || !navBarLanguagesAreTheSame,
                let remoteShareSelectedLocale = remoteShareSelectedLocale,
                let primaryLanguageId = getRemoteSharePrimaryLanguageId(remoteShareNavigationEvent: remoteShareNavigationEvent) {
            
            let parallelLanguageId: String? = getRemoteShareParallelLanguageId(remoteShareNavigationEvent: remoteShareNavigationEvent)
            
            super.setRendererPrimaryLanguage(
                primaryLanguageId: primaryLanguageId,
                parallelLanguageId: parallelLanguageId,
                selectedLanguageId: languagesRepository.getCachedLanguage(code: remoteShareSelectedLocale)?.id
            )
        }
        else {
            
            super.sendPageNavigationEvent(
                navigationEvent: getPagesNavigationEventForRemoteShareNavigationEvent(
                    remoteShareNavigationEvent: remoteShareNavigationEvent,
                    animated: animated,
                    reloadCollectionViewDataNeeded: false
                )
            )
        }
    }
    
    private func getRemoteSharePrimaryLanguageId(remoteShareNavigationEvent: TractRemoteShareNavigationEvent) -> String? {
        
        let attributes = remoteShareNavigationEvent.message?.data?.attributes
                
        if let primaryLocale = attributes?.primaryLocale, !primaryLocale.isEmpty {
            return languagesRepository.getCachedLanguage(code: primaryLocale)?.id
        }
        else if let locale = attributes?.locale, !locale.isEmpty {
            return languagesRepository.getCachedLanguage(code: locale)?.id
        }
        
        return nil
    }
    
    private func getRemoteShareParallelLanguageId(remoteShareNavigationEvent: TractRemoteShareNavigationEvent) -> String? {
        
        let attributes = remoteShareNavigationEvent.message?.data?.attributes
                
        if let parallelLocale = attributes?.parallelLocale, !parallelLocale.isEmpty {
            return languagesRepository.getCachedLanguage(code: parallelLocale)?.id
        }
        
        return nil
    }
    
    private func getRemoteShareNavBarLocales(remoteShareNavigationEvent: TractRemoteShareNavigationEvent) -> [String] {
        
        let attributes = remoteShareNavigationEvent.message?.data?.attributes
                        
        let remoteShareNavLocales: [String]
        
        if let primaryLocale = attributes?.primaryLocale, !primaryLocale.isEmpty {
            
            if let parallelLocale = attributes?.parallelLocale, !parallelLocale.isEmpty {
                remoteShareNavLocales = [primaryLocale, parallelLocale]
            }
            else {
                remoteShareNavLocales = [primaryLocale]
            }
        }
        else if let locale = attributes?.locale, !locale.isEmpty {
            remoteShareNavLocales = [locale]
        }
        else {
            remoteShareNavLocales = []
        }
        
        return remoteShareNavLocales
    }
    
    private func getPagePositionsForRemoteShareNavigationEvent(remoteShareNavigationEvent: TractRemoteShareNavigationEvent) -> TractPagePositions {
        
        let attributes = remoteShareNavigationEvent.message?.data?.attributes
        
        return TractPagePositions(
            cardPosition: attributes?.card
        )
    }
    
    private func getPagesNavigationEventForRemoteShareNavigationEvent(remoteShareNavigationEvent: TractRemoteShareNavigationEvent, animated: Bool, reloadCollectionViewDataNeeded: Bool) -> MobileContentPagesNavigationEvent {
        
        let attributes = remoteShareNavigationEvent.message?.data?.attributes
        
        let page: Int? = attributes?.page
        
        let pageNavigation = PageNavigationCollectionViewNavigationModel(
            navigationDirection: nil,
            page: page ?? super.currentPageNumber,
            animated: animated,
            reloadCollectionViewDataNeeded: reloadCollectionViewDataNeeded,
            insertPages: nil,
            deletePages: nil
        )
        
        let pagesNavigationEvent = MobileContentPagesNavigationEvent(
            pageNavigation: pageNavigation,
            setPages: nil,
            pagePositions: getPagePositionsForRemoteShareNavigationEvent(remoteShareNavigationEvent: remoteShareNavigationEvent),
            parentPageParams: nil,
            pageSubIndex: nil
        )
        
        return pagesNavigationEvent
    }
    
    func sendRemoteShareNavigationEvent(page: Int, pagePositions: TractPagePositions) {
        
        guard tractRemoteSharePublisher.isSubscriberChannelCreatedForPublish else {
            return
        }
                        
        let event = TractRemoteSharePublisherNavigationEvent(
            card: pagePositions.cardPosition,
            locale: languages[safe: selectedLanguageIndex]?.localeId,
            page: page,
            parallelLocale: languages[safe: 1]?.localeId,
            primaryLocale: languages[safe: 0]?.localeId,
            tool: resource.abbreviation
        )
        
        tractRemoteSharePublisher.sendNavigationEvent(event: event)
    }
}
