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
    
    private let backButtonImageType: ToolBackButtonImageType
    private let tractRemoteSharePublisher: TractRemoteSharePublisher
    private let tractRemoteShareSubscriber: TractRemoteShareSubscriber
    private let localizationServices: LocalizationServices
    private let fontService: FontService
    private let resourceViewsService: ResourceViewsService
    private let analytics: AnalyticsContainer
    private let toolOpenedAnalytics: ToolOpenedAnalytics
    private let liveShareStream: String?
    
    private weak var flowDelegate: FlowDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    let navBarViewModel: ObservableValue<ToolNavBarViewModel>
    let didSubscribeForRemoteSharePublishing: ObservableValue<Bool> = ObservableValue(value: false)
        
    init(flowDelegate: FlowDelegate, backButtonImageType: ToolBackButtonImageType, renderer: MobileContentRenderer, tractRemoteSharePublisher: TractRemoteSharePublisher, tractRemoteShareSubscriber: TractRemoteShareSubscriber, localizationServices: LocalizationServices, fontService: FontService, resourceViewsService: ResourceViewsService, analytics: AnalyticsContainer, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, mobileContentEventAnalytics: MobileContentEventAnalyticsTracking, toolOpenedAnalytics: ToolOpenedAnalytics, liveShareStream: String?, initialPage: MobileContentPagesPage?, trainingTipsEnabled: Bool, incrementUserCounterUseCase: IncrementUserCounterUseCase) {
        
        self.flowDelegate = flowDelegate
        self.backButtonImageType = backButtonImageType
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        self.tractRemoteShareSubscriber = tractRemoteShareSubscriber
        self.localizationServices = localizationServices
        self.fontService = fontService
        self.resourceViewsService = resourceViewsService
        self.analytics = analytics
        self.toolOpenedAnalytics = toolOpenedAnalytics
        self.liveShareStream = liveShareStream
        
        let navBarViewModelValue: ToolNavBarViewModel = ToolViewModel.navBarWillAppear(backButtonImageType: backButtonImageType, renderer: renderer, tractRemoteSharePublisher: tractRemoteSharePublisher, tractRemoteShareSubscriber: tractRemoteShareSubscriber, localizationServices: localizationServices, fontService: fontService, analytics: analytics, selectedLanguageValue: nil)
        
        self.navBarViewModel = ObservableValue(value: navBarViewModelValue)
        
        super.init(renderer: renderer, initialPage: initialPage, resourcesRepository: resourcesRepository, translationsRepository: translationsRepository, mobileContentEventAnalytics: mobileContentEventAnalytics, initialPageRenderingType: .visiblePages, trainingTipsEnabled: trainingTipsEnabled, incrementUserCounterUseCase: incrementUserCounterUseCase)
        
        setupBinding()
    }
    
    deinit {
                
        tractRemoteSharePublisher.didCreateNewSubscriberChannelIdForPublish.removeObserver(self)
        tractRemoteSharePublisher.endPublishingSession(disconnectSocket: true)
        
        tractRemoteShareSubscriber.navigationEventSignal.removeObserver(self)
        tractRemoteShareSubscriber.unsubscribe(disconnectSocket: true)
    }
    
    private func setupBinding() {
        
        tractRemoteSharePublisher.didCreateNewSubscriberChannelIdForPublish.addObserver(self) { [weak self] (channel: TractRemoteShareChannel) in
            DispatchQueue.main.async { [weak self] in
                self?.didSubscribeForRemoteSharePublishing.accept(value: true)
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
    
    private static func navBarWillAppear(backButtonImageType: ToolBackButtonImageType, renderer: MobileContentRenderer, tractRemoteSharePublisher: TractRemoteSharePublisher, tractRemoteShareSubscriber: TractRemoteShareSubscriber, localizationServices: LocalizationServices, fontService: FontService, analytics: AnalyticsContainer, selectedLanguageValue: Int?) -> ToolNavBarViewModel {
        
        let primaryManifest: Manifest = renderer.pageRenderers[0].manifest
        let languages: [LanguageDomainModel] = renderer.pageRenderers.map({$0.language})
        
        return ToolNavBarViewModel(
            backButtonImageType: backButtonImageType,
            resource: renderer.resource,
            manifest: primaryManifest,
            languages: languages,
            tractRemoteSharePublisher: tractRemoteSharePublisher,
            tractRemoteShareSubscriber: tractRemoteShareSubscriber,
            fontService: fontService,
            analytics: analytics,
            selectedLanguageValue: selectedLanguageValue
        )
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
        
        incrementUserCounterUseCase.incrementUserCounter(for: .toolOpen(tool: resource.id))
            .sink { _ in
                
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    override func setRenderer(renderer: MobileContentRenderer, pageRendererIndex: Int?) {
        
        let selectedLanguageValue: Int = navBarViewModel.value.selectedLanguage.value
        
        let viewModel = ToolViewModel.navBarWillAppear(backButtonImageType: backButtonImageType, renderer: renderer, tractRemoteSharePublisher: tractRemoteSharePublisher, tractRemoteShareSubscriber: tractRemoteShareSubscriber, localizationServices: localizationServices, fontService: fontService, analytics: analytics, selectedLanguageValue: selectedLanguageValue)
        
        navBarViewModel.accept(value: viewModel)
        
        super.setRenderer(renderer: renderer, pageRendererIndex: selectedLanguageValue)
    }
}

// MARK: - Inputs

extension ToolViewModel {
    
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
    
    func navHomeTapped(remoteShareIsActive: Bool) {
        flowDelegate?.navigate(step: .homeTappedFromTool(isScreenSharing: remoteShareIsActive))
    }
    
    func navToolSettingsTapped(page: Int, selectedLanguage: LanguageDomainModel) {
                            
        let toolData = ToolSettingsFlowToolData(
            renderer: renderer,
            currentPageRenderer: currentPageRenderer,
            tractRemoteSharePublisher: tractRemoteSharePublisher,
            pageNumber: page,
            trainingTipsEnabled: trainingTipsEnabled
        )
        
        flowDelegate?.navigate(step: .toolSettingsTappedFromTool(toolData: toolData))
    }
    
    func navLanguageChanged(page: Int, pagePositions: ToolPagePositions) {
        
        if let pageRenderer = getPageRenderer(language: navBarViewModel.value.language) {
            setPageRenderer(pageRenderer: pageRenderer)
        }
        
        sendRemoteShareNavigationEvent(
            page: page,
            pagePositions: pagePositions
        )
    }
}

// MARK: - Remote Share Subscriber / Publisher

extension ToolViewModel {
    
    private func trackShareScreenOpened() {
        
        let trackAction = TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.shareScreenOpened,
            siteSection: analyticsSiteSection,
            siteSubSection: "",
            contentLanguage: nil,
            secondaryContentLanguage: nil,
            url: nil,
            data: [
                AnalyticsConstants.Keys.shareScreenOpenedCountKey: 1
            ]
        )
        
        analytics.trackActionAnalytics.trackAction(trackAction: trackAction)
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
        
        let navBarLanguages: [LanguageDomainModel] = navBarViewModel.value.languages
        let currentNavBarLanguage: LanguageDomainModel = navBarViewModel.value.language
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
        let willReloadData: Bool = navBarLanguageChanged
                
        if let page = page {
            
            let pagePositions: ToolPagePositions = ToolPagePositions(cardPosition: cardPosition)
            
            let navigationModel = MobileContentPagesNavigationModel(
                willReloadData: willReloadData,
                page: page,
                pagePositions: pagePositions,
                animated: animated
            )
            
            // TODO: Implement in GT-2067. ~Levi
            //pageNavigation.accept(value: navigationModel)
        }
        
        if let remoteShareLanguageIndex = remoteShareLanguageIndex, navBarLanguageChanged {
            
            navBarViewModel.value.selectedLanguage.accept(value: remoteShareLanguageIndex)
            setPageRenderer(pageRenderer: renderer.value.pageRenderers[remoteShareLanguageIndex])
        }
    }
    
    private func sendRemoteShareNavigationEvent(page: Int, pagePositions: ToolPagePositions) {
        
        guard tractRemoteSharePublisher.isSubscriberChannelIdCreatedForPublish else {
            return
        }
                
        let event = TractRemoteSharePublisherNavigationEvent(
            card: pagePositions.cardPosition,
            locale: navBarViewModel.value.language.localeIdentifier,
            page: page,
            tool: resource.abbreviation
        )
        
        tractRemoteSharePublisher.sendNavigationEvent(event: event)
    }
}
