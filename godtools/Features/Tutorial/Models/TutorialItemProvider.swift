//
//  TutorialItemProvider.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TutorialItemProvider: TutorialItemProviderType {
    
    let tutorialItems: [TutorialItem]
    
    required init(localizationServices: LocalizationServices) {
        
        tutorialItems = [
            
            TutorialItem(
                title: localizationServices.stringForMainBundle(key: "tutorial.tutorialItem.0.title"),
                message: localizationServices.stringForMainBundle(key: "tutorial.tutorialItem.0.message"),
                imageName: nil,
                youTubeVideoId: "Us2psJs8izU",
                customViewId: nil
            ),
            TutorialItem(
                title: localizationServices.stringForMainBundle(key: "tutorial.tutorialItem.1.title"),
                message: localizationServices.stringForMainBundle(key: "tutorial.tutorialItem.1.message"),
                imageName: nil,
                youTubeVideoId: nil,
                customViewId: "tutorial_tools"
            ),
            TutorialItem(
                title: localizationServices.stringForMainBundle(key: "tutorial.tutorialItem.2.title"),
                message: localizationServices.stringForMainBundle(key: "tutorial.tutorialItem.2.message"),
                imageName: "tutorial_people",
                youTubeVideoId: nil,
                customViewId: nil
            ),
            TutorialItem(
                title: localizationServices.stringForMainBundle(key: "tutorial.tutorialItem.3.title"),
                message: "",
                imageName: nil,
                youTubeVideoId: nil,
                customViewId: "tutorial_in_menu"
            )
        ]
    }
}
