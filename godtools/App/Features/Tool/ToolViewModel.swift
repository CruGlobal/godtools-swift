//
//  ToolViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolViewModel: MobileContentPagesViewModel, ToolViewModelType {
    
    private let backButtonImageType: ToolBackButtonImageType
    private let resource: ResourceModel
    private let primaryLanguage: LanguageModel
    private let tractRemoteSharePublisher: TractRemoteSharePublisher
    private let tractRemoteShareSubscriber: TractRemoteShareSubscriber
    private let localizationServices: LocalizationServices
    private let fontService: FontService
    private let viewsService: ViewsService
    private let analytics: AnalyticsContainer
    private let toolOpenedAnalytics: ToolOpenedAnalytics
    private let liveShareStream: String?
    
    let navBarViewModel: ToolNavBarViewModel
    let didSubscribeForRemoteSharePublishing: ObservableValue<Bool> = ObservableValue(value: false)
        
    required init(flowDelegate: FlowDelegate, backButtonImageType: ToolBackButtonImageType, renderers: [MobileContentRendererType], resource: ResourceModel, primaryLanguage: LanguageModel, tractRemoteSharePublisher: TractRemoteSharePublisher, tractRemoteShareSubscriber: TractRemoteShareSubscriber, localizationServices: LocalizationServices, fontService: FontService, viewsService: ViewsService, analytics: AnalyticsContainer, mobileContentEventAnalytics: MobileContentEventAnalyticsTracking, toolOpenedAnalytics: ToolOpenedAnalytics, liveShareStream: String?, trainingTipsEnabled: Bool, page: Int?) {
        
        self.backButtonImageType = backButtonImageType
        self.resource = resource
        self.primaryLanguage = primaryLanguage
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        self.tractRemoteShareSubscriber = tractRemoteShareSubscriber
        self.localizationServices = localizationServices
        self.fontService = fontService
        self.viewsService = viewsService
        self.analytics = analytics
        self.toolOpenedAnalytics = toolOpenedAnalytics
        self.liveShareStream = liveShareStream
        
        let primaryManifest: MobileContentManifestType = renderers.first!.parser.manifest
        let languages: [LanguageModel] = renderers.map({$0.language})
        
        navBarViewModel = ToolNavBarViewModel(
            backButtonImageType: backButtonImageType,
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
        
        super.init(flowDelegate: flowDelegate, renderers: renderers, primaryLanguage: primaryLanguage, page: page, mobileContentEventAnalytics: mobileContentEventAnalytics, initialPageRenderingType: .visiblePages)
        
        setupBinding()
    }
    
    required init(flowDelegate: FlowDelegate, renderers: [MobileContentRendererType], primaryLanguage: LanguageModel, page: Int?, mobileContentEventAnalytics: MobileContentEventAnalyticsTracking, initialPageRenderingType: MobileContentPagesInitialPageRenderingType) {
        fatalError("init(flowDelegate:renderers:primaryLanguage:page:mobileContentEventAnalytics:initialPageRenderingType:) has not been implemented")
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
    
    private var parallelLanguage: LanguageModel? {
        if renderers.count > 1 {
            return renderers[1].language
        }
        return nil
    }
    
    private func getRenderer(language: LanguageModel) -> MobileContentRendererType? {
        for renderer in renderers {
            if renderer.language.code.lowercased() == language.code.lowercased() {
                return renderer
            }
        }
        return nil
    }
    
    override func viewDidFinishLayout(window: UIViewController, safeArea: UIEdgeInsets) {
        
        super.viewDidFinishLayout(window: window, safeArea: safeArea)
        
        subscribeToLiveShareStreamIfNeeded()
        
        _ = viewsService.postNewResourceView(resourceId: resource.id)
        
        toolOpenedAnalytics.trackFirstToolOpenedIfNeeded(resource: resource)
        toolOpenedAnalytics.trackToolOpened(resource: resource)
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
        
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(screenName: resource.abbreviation, actionName: AnalyticsConstants.Values.shareScreenOpened, siteSection: resource.abbreviation, siteSubSection: "", url: nil, data: [
            AnalyticsConstants.Keys.shareScreenOpenedCountKey: 1
        ]))
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
        
        let navBarLanguages: [LanguageModel] = navBarViewModel.languages
        let currentNavBarLanguage: LanguageModel = navBarViewModel.language
        var remoteShareLanguage: LanguageModel = currentNavBarLanguage
        var remoteShareLanguageIndex: Int?
        
        if let locale = attributes?.locale, !locale.isEmpty {
            
            for index in 0 ..< navBarLanguages.count {
                
                let language: LanguageModel = navBarLanguages[index]

                if locale.lowercased() == language.code.lowercased() {
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
            
            pageNavigation.accept(value: navigationModel)
        }
        
        if let remoteShareLanguageIndex = remoteShareLanguageIndex, navBarLanguageChanged {
            
            navBarViewModel.selectedLanguage.accept(value: remoteShareLanguageIndex)
            setRenderer(renderer: renderers[remoteShareLanguageIndex])
        }
    }
    
    private func sendRemoteShareNavigationEvent(page: Int, pagePositions: ToolPagePositions) {
        
        guard tractRemoteSharePublisher.isSubscriberChannelIdCreatedForPublish else {
            return
        }
                
        let event = TractRemoteSharePublisherNavigationEvent(
            card: pagePositions.cardPosition,
            locale: navBarViewModel.language.code,
            page: page,
            tool: resource.abbreviation
        )
        
        tractRemoteSharePublisher.sendNavigationEvent(event: event)
    }
}

// MARK: - Nav Bar

extension ToolViewModel {
    
    func navHomeTapped(remoteShareIsActive: Bool) {
        flowDelegate?.navigate(step: .homeTappedFromTool(isScreenSharing: remoteShareIsActive))
    }
    
    func navShareTapped(page: Int, selectedLanguage: LanguageModel) {
        
        flowDelegate?.navigate(step: .shareMenuTappedFromTool(tractRemoteShareSubscriber: tractRemoteShareSubscriber, tractRemoteSharePublisher: tractRemoteSharePublisher, resource: resource, selectedLanguage: selectedLanguage, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, pageNumber: page))
    }
    
    func navLanguageChanged(page: Int, pagePositions: ToolPagePositions) {
        
        if let renderer = getRenderer(language: navBarViewModel.language) {
            setRenderer(renderer: renderer)
        }
        
        sendRemoteShareNavigationEvent(
            page: page,
            pagePositions: pagePositions
        )
    }
}
