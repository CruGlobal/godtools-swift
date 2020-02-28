//
//  OpenTutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OpenTutorialViewModel: NSObject, OpenTutorialViewModelType {
    
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
        
        super.init()
        
        tutorialServices.openTutorialCalloutDisabledSignal.addObserver(self) { [weak self] in
            self?.hidesOpenTutorial.accept(value: (hidden: true, animated: true))
        }
    }
    
    func openTutorialTapped() {
        tutorialServices.disableOpenTutorialCallout()
        flowDelegate?.navigate(step: .openTutorialTapped)
    }
    
    func closeTapped() {
        tutorialServices.disableOpenTutorialCallout()
        analytics.recordActionForADBMobile(screenName: "home", actionName: "Tutorial Home Dismiss", data: ["cru.tutorial_home_dismiss": 1])
    }
}
