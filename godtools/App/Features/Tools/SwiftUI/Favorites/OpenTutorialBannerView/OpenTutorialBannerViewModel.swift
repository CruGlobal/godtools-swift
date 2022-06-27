//
//  OpenTutorialBannerViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol OpenTutorialBannerViewModelDelegate: BannerViewModelDelegate {
    func openTutorial()
}

class OpenTutorialBannerViewModel: BannerViewModel {
    
    // MARK: - Properties
    
    private let getTutorialIsAvailableUseCase: GetTutorialIsAvailableUseCase
    private let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    private let localizationServices: LocalizationServices
    private let analytics: AnalyticsContainer
    private weak var flowDelegate: FlowDelegate?
    
    var openTutorialBannerViewModelDelegate: OpenTutorialBannerViewModelDelegate? {
        return delegate as? OpenTutorialBannerViewModelDelegate
    }
    
    // MARK: - Published
    
    @Published var showTutorialText: String
    @Published var openTutorialButtonText: String
    
    // MARK: - Init
    
    init(flowDelegate: FlowDelegate?, getTutorialIsAvailableUseCase: GetTutorialIsAvailableUseCase, openTutorialCalloutCache: OpenTutorialCalloutCacheType, localizationServices: LocalizationServices, analytics: AnalyticsContainer, delegate: OpenTutorialBannerViewModelDelegate?) {
        
        self.flowDelegate = flowDelegate
        self.getTutorialIsAvailableUseCase = getTutorialIsAvailableUseCase
        self.openTutorialCalloutCache = openTutorialCalloutCache
        self.localizationServices = localizationServices
        self.analytics = analytics
        
        showTutorialText = localizationServices.stringForMainBundle(key: "openTutorial.showTutorialLabel.text")
        openTutorialButtonText = localizationServices.stringForMainBundle(key: "openTutorial.openTutorialButton.title")
        
        super.init(delegate: delegate)
    }
    
    // MARK: - Overrides
    
    override func closeTapped() {
        super.closeTapped()
        
        trackCloseTapped()
    }
}

// MARK: - Public

extension OpenTutorialBannerViewModel {
    
    func openTutorialButtonTapped() {
        openTutorialBannerViewModelDelegate?.openTutorial()
    }
}

// MARK: - Analytics

extension OpenTutorialBannerViewModel {
    
    private var analyticsScreenName: String {
        return "home"
    }
    
    private func trackCloseTapped() {
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(screenName: analyticsScreenName, actionName: AnalyticsConstants.ActionNames.tutorialHomeDismiss, siteSection: "", siteSubSection: "", url: nil, data: [AnalyticsConstants.Keys.tutorialDismissed: 1]))
    }
}
