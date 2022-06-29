//
//  OpenTutorialBannerViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol OpenTutorialBannerViewModelDelegate: AnyObject {
    func closeBanner()
    func openTutorial()
}

class OpenTutorialBannerViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    private let getTutorialIsAvailableUseCase: GetTutorialIsAvailableUseCase
    private let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    private let localizationServices: LocalizationServices
    private let analytics: AnalyticsContainer
    private weak var flowDelegate: FlowDelegate?
    private weak var delegate: OpenTutorialBannerViewModelDelegate?
    
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
        self.delegate = delegate
        
        showTutorialText = localizationServices.stringForMainBundle(key: "openTutorial.showTutorialLabel.text")
        openTutorialButtonText = localizationServices.stringForMainBundle(key: "openTutorial.openTutorialButton.title")
    }
}

// MARK: - Public

extension OpenTutorialBannerViewModel {
    
    func closeTapped() {
        delegate?.closeBanner()
        trackCloseTapped()
    }
    
    func openTutorialButtonTapped() {
        delegate?.openTutorial()
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
