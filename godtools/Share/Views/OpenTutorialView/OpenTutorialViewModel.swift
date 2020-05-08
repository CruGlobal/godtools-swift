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
    private let analytics: AnalyticsContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    let showTutorialTitle: String
    let openTutorialTitle: String
    let hidesOpenTutorial: ObservableValue<(hidden: Bool, animated: Bool)>
    
    required init(flowDelegate: FlowDelegate, tutorialAvailability: TutorialAvailabilityType, openTutorialCalloutCache: OpenTutorialCalloutCacheType, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.tutorialAvailability = tutorialAvailability
        self.openTutorialCalloutCache = openTutorialCalloutCache
        self.analytics = analytics
        
        showTutorialTitle = NSLocalizedString("openTutorial.showTutorialLabel.text", comment: "")
        openTutorialTitle = NSLocalizedString("openTutorial.openTutorialButton.title", comment: "")
        
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
        analytics.adobeAnalytics.trackAction(screenName: "home", actionName: "Tutorial Home Dismiss", data: ["cru.tutorial_home_dismiss": 1])
    }
}
