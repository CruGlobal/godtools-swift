//
//  TractViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsShared
import Combine

@MainActor
final class TractViewModel: MobileContentRendererViewModel {
        
    static let isLiveShareStreamingKey: String = "TractViewModel.isLiveShareStreamKey"
    
    private let stepEmitter: FlowStepEmitter
    private let tractRemoteSharePublisher: TractRemoteSharePublisher
    private let tractRemoteShareSubscriber: TractRemoteShareSubscriber
    private let languagesRepository: LanguagesRepository
    private let resourceViewsService: ResourceViewsService
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let liveShareStream: String?
    private let persistToolLanguageSettings: PersistToolLanguageSettingsInterface?
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var remoteShareIsActive: Bool = false
        
    let navBarAppearance: AppNavigationBarAppearance
    let languageFont: UIFont?
    let didSubscribeForRemoteSharePublishing: ObservableValue<Bool> = ObservableValue(value: false)
    
    @Published private(set) var toolSettingsDidClose: Void?
    @Published private(set) var hidesRemoteShareIsActive: Bool = true
        
    init(
        stepEmitter: FlowStepEmitter,
        renderer: MobileContentRenderer,
        tractRemoteSharePublisher: TractRemoteSharePublisher,
        tractRemoteShareSubscriber: TractRemoteShareSubscriber,
        languagesRepository: LanguagesRepository,
        resourceViewsService: ResourceViewsService,
        trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase,
        resourcesRepository: ResourcesRepository,
        translationsRepository: TranslationsRepository,
        mobileContentEventAnalytics: MobileContentRendererEventAnalyticsTracking,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getTranslatedLanguageName: GetTranslatedLanguageName,
        liveShareStream: String?,
        initialPage: MobileContentRendererInitialPage?,
        initialPageSubIndex: Int?,
        trainingTipsEnabled: Bool,
        incrementUserCounterUseCase: IncrementUserCounterUseCase,
        selectedLanguageIndex: Int?,
        persistToolLanguageSettings: PersistToolLanguageSettingsInterface?
    ) {
        
        self.stepEmitter = stepEmitter
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
        
        super.init(
            renderer: renderer,
            initialPage: initialPage,
            initialPageConfig: nil,
            initialPageSubIndex: initialPageSubIndex,
            resourcesRepository: resourcesRepository,
            translationsRepository: translationsRepository,
            mobileContentEventAnalytics: mobileContentEventAnalytics,
            getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase,
            getTranslatedLanguageName: getTranslatedLanguageName,
            trainingTipsEnabled: trainingTipsEnabled,
            incrementUserCounterUseCase: incrementUserCounterUseCase,
            selectedLanguageIndex: selectedLanguageIndex
        )
        
        Task { [weak self] in
           
            guard let createdChannelStream = await self?.tractRemoteSharePublisher.getCreatedChannelStream() else {
                return
            }
            
            for await _ in createdChannelStream {
                
                self?.didSubscribeForRemoteSharePublishing.accept(value: true)
                self?.reloadRemoteShareIsActive()
            }
        }
        
        Task { [weak self] in
            
            guard let navigationEventStream = await self?.tractRemoteShareSubscriber.getNavigationEventStream() else {
                return
            }
            
            var isFirstRemoteShareNavigationEvent: Bool = true
            
            for await navigationEvent in navigationEventStream {
                
                let animated: Bool = !isFirstRemoteShareNavigationEvent
                self?.handleDidReceiveRemoteShareNavigationEvent(remoteShareNavigationEvent: navigationEvent, animated: animated)
                isFirstRemoteShareNavigationEvent = false
            }
        }
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private var isScreenSharing: Bool {
        return remoteShareIsActive
    }
    
    private var isLiveStreaming: Bool {
        get async {
            
            let liveShareStreamChannelIdIsEmpty: Bool = (liveShareStream?.isEmpty) ?? true
            let publisherIsConnected: Bool = await tractRemoteSharePublisher.connectionState.isConnected
            let subscriberIsConnected: Bool = await tractRemoteShareSubscriber.connectionState.isConnected
            
            return publisherIsConnected || subscriberIsConnected || !liveShareStreamChannelIdIsEmpty
        }
    }
    
    private func reloadRemoteShareIsActive() {
        
        Task { [weak self] in
            
            guard let weakSelf = self else {
                return
            }
            
            let publisherSubscriberChannelIsCreated: Bool = await weakSelf.tractRemoteSharePublisher.subscriberChannelCreated
            let isSubscribedToChannel: Bool = await weakSelf.tractRemoteShareSubscriber.isSubscribedToChannel
            let remoteShareIsActive: Bool = publisherSubscriberChannelIsCreated || isSubscribedToChannel
            
            weakSelf.remoteShareIsActive = remoteShareIsActive
            
            weakSelf.hidesRemoteShareIsActive = !remoteShareIsActive
        }
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
        
        let resourceViewsService: ResourceViewsService = self.resourceViewsService
        let resourceId: String = resource.id
        
        Task.detached {
            
            try await resourceViewsService.postNewResourceView(
                resourceId: resourceId,
                requestPriority: .medium
            )
        }
    }
    
    private func trackLanguageTapped(tappedLanguage: LanguageDataModel) {
        
        let primaryLanguage: LanguageDataModel = languages[0]
        let parallelLanguage: LanguageDataModel? = languages[safe: 1]
                
        let parallelLanguageLocaleId: String? = parallelLanguage?.localeId
        let parallelLanguageToggled: Bool = tappedLanguage.id == parallelLanguage?.id
        
        let analyticsProperties = AnalyticsProperties(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: "",
            appLanguage: nil,
            contentLanguage: primaryLanguage.localeId,
            secondaryContentLanguage: parallelLanguageLocaleId
        )
        let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase = self.trackActionAnalyticsUseCase
        
        Task.detached {
            await trackActionAnalyticsUseCase.execute(
                properties: analyticsProperties,
                actionName: AnalyticsConstants.ActionNames.parallelLanguageToggled,
                data: [
                    AnalyticsConstants.Keys.contentLanguageSecondary: parallelLanguageLocaleId ?? "",
                    AnalyticsConstants.ActionNames.parallelLanguageToggled: parallelLanguageToggled
                ]
            )
        }
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
                    
                    guard let weakSelf = self else {
                        return Just(false)
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                    
                    return AnyPublisher() {
                        try await persistToolLanguageSettings.persistSettings(
                            toolId: weakSelf.renderer.value.resource.id,
                            primaryLanguageId: languages.primaryLanguageId,
                            parallelLanguageId: languages.parallelLanguageId
                        )
                    }
                }
                .switchToLatest()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { _ in
                    
                })
                .store(in: &cancellables)
        }
        
        return attachedToolSettingsObserver
    }
    
    override func configureRendererPageContextUserInfo(userInfo: inout [String: Any], page: Int) {
        
        userInfo[TractViewModel.isLiveShareStreamingKey] = liveShareStream != nil
        
        super.configureRendererPageContextUserInfo(userInfo: &userInfo, page: page)
    }
}

// MARK: - Inputs

extension TractViewModel {
    
    @objc func homeTapped() {
                
        stepEmitter.emit(step: AppFlowStep.homeTappedFromTool(isScreenSharing: isScreenSharing))
    }
    
    @objc func backTapped() {
                
        stepEmitter.emit(step: AppFlowStep.backTappedFromTool(isScreenSharing: isScreenSharing))
    }
    
    @objc func toolSettingsTapped() {
        
        let toolSettingsDidCloseClosure = { [weak self] () -> Void in
            self?.toolSettingsDidClose = ()
        }
        
        let toolSettingsObserver = setUpToolSettingsObserver()
        
        let analyticsProperties = AnalyticsProperties(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: "",
            appLanguage: nil,
            contentLanguage: nil,
            secondaryContentLanguage: nil
        )
        let toolSettingsActionName: String = ToolAnalyticsActionNames.shared.ACTION_SETTINGS
        let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase = self.trackActionAnalyticsUseCase
        
        Task.detached {
            await trackActionAnalyticsUseCase
                .execute(
                    properties: analyticsProperties,
                    actionName: AnalyticsConstants.ActionNames.toolSettings,
                    data: [toolSettingsActionName: 1]
                )
        }
        
        stepEmitter.emit(step: AppFlowStep.toolSettingsTappedFromTool(toolSettingsObserver: toolSettingsObserver, toolSettingsDidCloseClosure: toolSettingsDidCloseClosure))
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
        
        let analyticsProperties = AnalyticsProperties(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: "",
            appLanguage: nil,
            contentLanguage: nil,
            secondaryContentLanguage: nil
        )
        let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase = self.trackActionAnalyticsUseCase
        
        Task.detached {
            await trackActionAnalyticsUseCase.execute(
                properties: analyticsProperties,
                actionName: AnalyticsConstants.ActionNames.shareScreenOpened,
                data: [
                    AnalyticsConstants.Keys.shareScreenOpenedCountKey: 1
                ]
            )
        }
    }
    
    private func subscribeToLiveShareStreamIfNeeded() {
        
        guard let channelId = liveShareStream, let channel = WebSocketChannel(id: channelId) else {
            return
        }
        
        Task { [weak self] in
            
            guard let didSubscribeStream = await self?.tractRemoteShareSubscriber.getSubscribedStream() else {
                return
            }
            
            for await _ in didSubscribeStream {
                
                self?.trackShareScreenOpened()
                self?.reloadRemoteShareIsActive()
            }
        }
        
        Task { [weak self] in
            
            try await self?.tractRemoteShareSubscriber
                .subscribe(channel: channel)
        }
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
                selectedLanguageId: languagesRepository.getLanguageByCode(code: remoteShareSelectedLocale)?.id
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
            return languagesRepository.getLanguageByCode(code: primaryLocale)?.id
        }
        else if let locale = attributes?.locale, !locale.isEmpty {
            return languagesRepository.getLanguageByCode(code: locale)?.id
        }
        
        return nil
    }
    
    private func getRemoteShareParallelLanguageId(remoteShareNavigationEvent: TractRemoteShareNavigationEvent) -> String? {
        
        let attributes = remoteShareNavigationEvent.message?.data?.attributes
                
        if let parallelLocale = attributes?.parallelLocale, !parallelLocale.isEmpty {
            return languagesRepository.getLanguageByCode(code: parallelLocale)?.id
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
        
        let event = TractRemoteSharePublisherNavigationEvent(
            card: pagePositions.cardPosition,
            locale: languages[safe: selectedLanguageIndex]?.localeId,
            page: page,
            parallelLocale: languages[safe: 1]?.localeId,
            primaryLocale: languages[safe: 0]?.localeId,
            tool: resource.abbreviation
        )
        
        Task { [weak self] in
        
            let subscriberCreated: Bool = await self?.tractRemoteSharePublisher.subscriberChannelCreated ?? false
            
            guard subscriberCreated else {
                return
            }
            
            await self?.tractRemoteSharePublisher.sendNavigationEvent(event: event)
        }
    }
}
