//
//  OpenTutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OpenTutorialViewModel: OpenTutorialViewModelType {
    
    private let tutorialServices: TutorialServicesType
    private let analytics: GodToolsAnaltyics
    
    private weak var flowDelegate: FlowDelegate?
    
    let showTutorialTitle: String
    let openTutorialTitle: String
    let hidesOpenTutorial: ObservableValue<(hidden: Bool, animated: Bool)>
    
    required init(flowDelegate: FlowDelegate, tutorialServices: TutorialServicesType, analytics: GodToolsAnaltyics) {
        
        self.flowDelegate = flowDelegate
        self.tutorialServices = tutorialServices
        self.analytics = analytics
        
        showTutorialTitle = NSLocalizedString("openTutorial.showTutorialLabel.text", comment: "")
        openTutorialTitle = NSLocalizedString("openTutorial.openTutorialButton.title", comment: "")
        hidesOpenTutorial = ObservableValue(value: (hidden: !tutorialServices.openTutorialCalloutIsAvailable, animated: false))
    }
    
    func openTutorialTapped() {
        tutorialServices.disableOpenTutorialCallout()
        hidesOpenTutorial.accept(value: (hidden: true, animated: true))
        flowDelegate?.navigate(step: .openTutorialTapped)
    }
    
    func closeTapped() {
        tutorialServices.disableOpenTutorialCallout()
        hidesOpenTutorial.accept(value: (hidden: true, animated: true))
        
        analytics.recordActionForADBMobile(screenName: "home", actionName: "Close Tutorial Notification", data: ["cru.tutorial_notification_close": 1])
    }
}
