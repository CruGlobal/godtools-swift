//
//  OpenTutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OpenTutorialViewModel: OpenTutorialViewModelType {
    
    private weak var flowDelegate: FlowDelegate?
    
    let showTutorialTitle: String
    let openTutorialTitle: String
    
    required init(flowDelegate: FlowDelegate) {
        
        self.flowDelegate = flowDelegate
        
        showTutorialTitle = NSLocalizedString("openTutorial.showTutorialLabel.text", comment: "")
        openTutorialTitle = NSLocalizedString("openTutorial.openTutorialButton.title", comment: "")
    }
    
    func openTutorialTapped() {
        flowDelegate?.navigate(step: .openTutorialTapped)
    }
}
