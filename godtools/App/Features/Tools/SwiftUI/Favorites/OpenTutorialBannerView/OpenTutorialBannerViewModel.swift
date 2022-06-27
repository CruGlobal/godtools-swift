//
//  OpenTutorialBannerViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class OpenTutorialBannerViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    private let getTutorialIsAvailableUseCase: GetTutorialIsAvailableUseCase
    private let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    private let localizationServices: LocalizationServices
    private let analytics: AnalyticsContainer
    private weak var flowDelegate: FlowDelegate?
    
    // MARK: - Published
    
    @Published var showTutorialText: String
    @Published var openTutorialButtonText: String
    
    // MARK: - Init
    
    init(flowDelegate: FlowDelegate?, getTutorialIsAvailableUseCase: GetTutorialIsAvailableUseCase, openTutorialCalloutCache: OpenTutorialCalloutCacheType, localizationServices: LocalizationServices, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.getTutorialIsAvailableUseCase = getTutorialIsAvailableUseCase
        self.openTutorialCalloutCache = openTutorialCalloutCache
        self.localizationServices = localizationServices
        self.analytics = analytics
        
        showTutorialText = localizationServices.stringForMainBundle(key: "openTutorial.showTutorialLabel.text")
        openTutorialButtonText = localizationServices.stringForMainBundle(key: "openTutorial.openTutorialButton.title")
    }
}

// MARK: - Public

extension OpenTutorialBannerViewModel {
    
    func openTutorialButtonTapped() {
        
    }
    
    func closeButtonTapped() {
        openTutorialCalloutCache.disableOpenTutorialCallout()
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(screenName: analyticsScreenName, actionName: AnalyticsConstants.ActionNames.tutorialHomeDismiss, siteSection: "", siteSubSection: "", url: nil, data: [AnalyticsConstants.Keys.tutorialDismissed: 1]))
    }
    
    private var analyticsScreenName: String {
        return "home"
    }
}
