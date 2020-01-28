//
//  TutorialItemProvider.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct TutorialItemProvider: TutorialItemProviderType {
    
    let tutorialItems: [TutorialItem]
    
    init() {
        
        tutorialItems = [
            
            TutorialItem(
                title: NSLocalizedString("tutorial.tutorialItem.0.title", comment: ""),
                message: NSLocalizedString("tutorial.tutorialItem.0.message", comment: ""),
                imageName: nil,
                youTubeVideoId: nil
            ),
            TutorialItem(
                title: NSLocalizedString("tutorial.tutorialItem.1.title", comment: ""),
                message: NSLocalizedString("tutorial.tutorialItem.1.message", comment: ""),
                imageName: nil,
                youTubeVideoId: nil
            ),
            TutorialItem(
                title: NSLocalizedString("tutorial.tutorialItem.2.title", comment: ""),
                message: NSLocalizedString("tutorial.tutorialItem.2.message", comment: ""),
                imageName: nil,
                youTubeVideoId: nil
            ),
            TutorialItem(
                title: NSLocalizedString("tutorial.tutorialItem.3.title", comment: ""),
                message: "",
                imageName: nil,
                youTubeVideoId: nil
            )
        ]
    }
}
