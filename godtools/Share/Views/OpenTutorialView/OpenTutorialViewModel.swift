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
    
    private weak var flowDelegate: FlowDelegate?
    
    let showTutorialTitle: String
    let openTutorialTitle: String
    
    required init(flowDelegate: FlowDelegate, tutorialServices: TutorialServicesType) {
        
        self.flowDelegate = flowDelegate
        self.tutorialServices = tutorialServices
        
        showTutorialTitle = NSLocalizedString("openTutorial.showTutorialLabel.text", comment: "")
        openTutorialTitle = NSLocalizedString("openTutorial.openTutorialButton.title", comment: "")
    }
    
    func openTutorialTapped() {
        flowDelegate?.navigate(step: .openTutorialTapped)
    }
    
    func closeTapped() {
        tutorialServices.disableOpenTutorialCallout()
    }
}
