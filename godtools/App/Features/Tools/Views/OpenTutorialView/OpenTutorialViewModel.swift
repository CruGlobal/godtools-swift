//
//  OpenTutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OpenTutorialViewModel: NSObject, OpenTutorialViewModelType {
    
    private let getTutorialIsAvailableUseCase: GetTutorialIsAvailableUseCase
    private let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    private let localizationServices: LocalizationServices
    private let analytics: AnalyticsContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    let showTutorialTitle: String
    let openTutorialTitle: String
    let hidesOpenTutorial: ObservableValue<AnimatableValue<Bool>>
    
    required init(flowDelegate: FlowDelegate, getTutorialIsAvailableUseCase: GetTutorialIsAvailableUseCase, openTutorialCalloutCache: OpenTutorialCalloutCacheType, localizationServices: LocalizationServices, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.getTutorialIsAvailableUseCase = getTutorialIsAvailableUseCase
        self.openTutorialCalloutCache = openTutorialCalloutCache
        self.localizationServices = localizationServices
        self.analytics = analytics
        
        showTutorialTitle = localizationServices.stringForMainBundle(key: "openTutorial.showTutorialLabel.text")
        openTutorialTitle = localizationServices.stringForMainBundle(key: "openTutorial.openTutorialButton.title")
        
        let hidesOpenTutorialCallout: Bool = !getTutorialIsAvailableUseCase.getTutorialIsAvailable() || openTutorialCalloutCache.openTutorialCalloutDisabled
        hidesOpenTutorial = ObservableValue(value: AnimatableValue(value: hidesOpenTutorialCallout, animated: false))
        
        super.init()
        
        openTutorialCalloutCache.openTutorialCalloutDisabledSignal.addObserver(self) { [weak self] in
            self?.hidesOpenTutorial.accept(value: AnimatableValue(value: true, animated: true))
        }
    }
    
    private var analyticsScreenName: String {
        return "home"
    }
        
    func openTutorialTapped() {
        openTutorialCalloutCache.disableOpenTutorialCallout()
        flowDelegate?.navigate(step: .openTutorialTappedFromTools)
    }
    
    func closeTapped() {
        openTutorialCalloutCache.disableOpenTutorialCallout()
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(screenName: analyticsScreenName, actionName: AnalyticsConstants.ActionNames.tutorialHomeDismiss, siteSection: "", siteSubSection: "", url: nil, data: [AnalyticsConstants.Keys.tutorialDismissAction: 1]))
    }
}
