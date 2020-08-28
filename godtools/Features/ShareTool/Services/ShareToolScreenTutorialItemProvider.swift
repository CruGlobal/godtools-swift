//
//  ShareToolScreenTutorialItemProvider.swift
//  godtools
//
//  Created by Levi Eggert on 8/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ShareToolScreenTutorialItemProvider: TutorialItemProviderType {
    
    let tutorialItems: [TutorialItem]
    
    required init(localizationServices: LocalizationServices) {
        
        tutorialItems = [
            
            TutorialItem(
                title: localizationServices.stringForMainBundle(key: "share_tool_screen_tutorial.share_your_screen.title"),
                message: localizationServices.stringForMainBundle(key: "share_tool_screen_tutorial.share_your_screen.message"),
                imageName: "share_tool_tutorial_people",
                youTubeVideoId: nil,
                customViewId: nil
            ),
            TutorialItem(
                title: localizationServices.stringForMainBundle(key: "share_tool_screen_tutorial.mirrored_experience.title"),
                message: localizationServices.stringForMainBundle(key: "share_tool_screen_tutorial.mirrored_experience.message"),
                imageName: "share_tool_tutorial_mirrored",
                youTubeVideoId: nil,
                customViewId: nil
            ),
            TutorialItem(
                title: localizationServices.stringForMainBundle(key: "share_tool_screen_tutorial.get_started.title"),
                message: localizationServices.stringForMainBundle(key: "share_tool_screen_tutorial.get_started.message"),
                imageName: "share_tool_tutorial_link",
                youTubeVideoId: nil,
                customViewId: nil
            )
        ]
    }
}
