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
                title: "",
                message: "",
                imageName: nil,
                youTubeVideoId: nil
            ),
            TutorialItem(
                title: "",
                message: "",
                imageName: nil,
                youTubeVideoId: nil
            ),
            TutorialItem(
                title: "",
                message: "",
                imageName: nil,
                youTubeVideoId: nil
            ),
            TutorialItem(
                title: "",
                message: "",
                imageName: nil,
                youTubeVideoId: nil
            )
        ]
    }
}
