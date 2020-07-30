//
//  OpenTutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OpenTutorialViewModel: NSObject, OpenTutorialViewModelType {
    
    private let tutorialAvailability: TutorialAvailabilityType
    private let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    private let localizationServices: LocalizationServices
    private let analytics: AnalyticsContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    let showTutorialTitle: String
    let openTutorialTitle: String
    let hidesOpenTutorial: ObservableValue<(hidden: Bool, animated: Bool)>
    
    required init(flowDelegate: FlowDelegate, tutorialAvailability: TutorialAvailabilityType, openTutorialCalloutCache: OpenTutorialCalloutCacheType, localizationServices: LocalizationServices, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.tutorialAvailability = tutorialAvailability
        self.openTutorialCalloutCache = openTutorialCalloutCache
        self.localizationServices = localizationServices
        self.analytics = analytics
        
        showTutorialTitle = localizationServices.stringForMainBundle(key: "openTutorial.showTutorialLabel.text")
        openTutorialTitle = localizationServices.stringForMainBundle(key: "openTutorial.openTutorialButton.title")
        
        let hidesOpenTutorialCallout: Bool = !tutorialAvailability.tutorialIsAvailable || openTutorialCalloutCache.openTutorialCalloutDisabled
        hidesOpenTutorial = ObservableValue(value: (hidden: hidesOpenTutorialCallout, animated: false))
        
        super.init()
        
        openTutorialCalloutCache.openTutorialCalloutDisabledSignal.addObserver(self) { [weak self] in
            self?.hidesOpenTutorial.accept(value: (hidden: true, animated: true))
        }
    }
    
    func openTutorialTapped() {
        openTutorialCalloutCache.disableOpenTutorialCallout()
        flowDelegate?.navigate(step: .openTutorialTapped)
    }
    
    func closeTapped() {
        openTutorialCalloutCache.disableOpenTutorialCallout()
        analytics.trackActionAnalytics.trackAction(screenName: "home", actionName: "Tutorial Home Dismiss", data: ["cru.tutorial_home_dismiss": 1])
    }
}
