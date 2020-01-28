//
//  OpenTutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OpenTutorialViewModel: OpenTutorialViewModelType {
    
    let showTutorialTitle: String
    let openTutorialTitle: String
    
    required init() {
        
        showTutorialTitle = NSLocalizedString("openTutorial.showTutorialLabel.text", comment: "")
        openTutorialTitle = NSLocalizedString("openTutorial.openTutorialButton.title", comment: "")
    }
    
    func openTutorialTapped() {
        print("open tutorial")
    }
    
    func closeTapped() {
        print("close tutorial")
    }
}
