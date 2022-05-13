//
//  ToolViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class ToolViewModel: MobileContentPagesViewModel, ToolViewModelType {
    
    private let backButtonImageType: ToolBackButtonImageType
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
        
    required init(flowDelegate: FlowDelegate, backButtonImageType: ToolBackButtonImageType, renderer: MobileContentRenderer, tractRemoteSharePublisher: TractRemoteSharePublisher, tractRemoteShareSubscriber: TractRemoteShareSubscriber, localizationServices: LocalizationServices, fontService: FontService, viewsService: ViewsService, analytics: AnalyticsContainer, mobileContentEventAnalytics: MobileContentEventAnalyticsTracking, toolOpenedAnalytics: ToolOpenedAnalytics, liveShareStream: String?, page: Int?) {
        
        self.backButtonImageType = backButtonImageType
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        self.tractRemoteShareSubscriber = tractRemoteShareSubscriber
        self.localizationServices = localizationServices
        self.fontService = fontService
        self.viewsService = viewsService
        self.analytics = analytics
        self.toolOpenedAnalytics = toolOpenedAnalytics
        self.liveShareStream = liveShareStream
        
        let primaryManifest: Manifest = renderer.pageRenderers[0].manifest
        let languages: [LanguageModel] = renderer.pageRenderers.map({$0.language})
        
        navBarViewModel = ToolNavBarViewModel(
            backButtonImageType: backButtonImageType,
            resource: renderer.resource,
            manifest: primaryManifest,
            languages: languages,
            tractRemoteSharePublisher: tractRemoteSharePublisher,
            tractRemoteShareSubscriber: tractRemoteShareSubscriber,
            localizationServices: localizationServices,
            fontService: fontService,
            analytics: analytics
        )
        
        super.init(flowDelegate: flowDelegate, renderer: renderer, page: page, mobileContentEventAnalytics: mobileContentEventAnalytics, initialPageRenderingType: .visiblePages)
        
        setupBinding()
    }
    
    required init(flowDelegate: FlowDelegate, renderer: MobileContentRenderer, page: Int?, mobileContentEventAnalytics: MobileContentEventAnalyticsTracking, initialPageRenderingType: MobileContentPagesInitialPageRenderingType) {
        fatalError("init(flowDelegate:renderer:page:mobileContentEventAnalytics:initialPageRenderingType:) has not been implemented")
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

    private var resource: ResourceModel {
        return renderer.resource
    }

    private var analyticsScreenName: String {
        return resource.abbreviation
    }
    
    private var analyticsSiteSection: String {
        return resource.abbreviation
    }
        
    private var parallelLanguage: LanguageModel? {
        if renderer.pageRenderers.count > 1 {
            return renderer.pageRenderers[1].language
        }
        return nil
    }
    
    private func getPageRenderer(language: LanguageModel) -> MobileContentPageRenderer? {
        for pageRenderer in renderer.pageRenderers {
            if pageRenderer.language.code.lowercased() == language.code.lowercased() {
                return pageRenderer
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
        
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(screenName: analyticsScreenName, actionName: AnalyticsConstants.ActionNames.shareScreenOpened, siteSection: analyticsSiteSection, siteSubSection: "", url: nil, data: [
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
            setPageRenderer(pageRenderer: renderer.pageRenderers[remoteShareLanguageIndex])
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
    
    func navToolSettingsTapped(page: Int, selectedLanguage: LanguageModel) {
        
        let primaryLanguage: LanguageModel = renderer.primaryLanguage
        
        flowDelegate?.navigate(step: .toolSettingsTappedFromTool(tractRemoteShareSubscriber: tractRemoteShareSubscriber, tractRemoteSharePublisher: tractRemoteSharePublisher, resource: resource, selectedLanguage: selectedLanguage, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, pageNumber: page))
    }
    
    func navLanguageChanged(page: Int, pagePositions: ToolPagePositions) {
        
        if let pageRenderer = getPageRenderer(language: navBarViewModel.language) {
            setPageRenderer(pageRenderer: pageRenderer)
        }
        
        sendRemoteShareNavigationEvent(
            page: page,
            pagePositions: pagePositions
        )
    }
}
