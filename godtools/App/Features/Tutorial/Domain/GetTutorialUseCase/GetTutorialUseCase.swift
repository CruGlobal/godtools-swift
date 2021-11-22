//
//  GetTutorialUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/22/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class GetTutorialUseCase {
    
    private let localizationServices: LocalizationServices
    private let deviceLanguage: DeviceLanguageType
    
    required init(localizationServices: LocalizationServices, deviceLanguage: DeviceLanguageType) {
        
        self.localizationServices = localizationServices
        self.deviceLanguage = deviceLanguage
    }
    
    func getTutorial() -> TutorialModel {
        
        let tutorialItems: [TutorialItemType]
        
        if deviceLanguage.isEnglish {
            
            tutorialItems = getEnglishTutorialItems()
        }
        else {
            
            tutorialItems = getNonEnglishTutorialItems()
        }
        
        return TutorialModel(tutorialItems: tutorialItems)
    }
    
    private func getEnglishTutorialItems() -> [TutorialItemType] {
        
        let tutorialItems: [TutorialItem] = [
            
            TutorialItem(
                title: "Tools",
                message: "Each tool is made for a different stage of conversation– before, during or after.",
                imageName: nil,
                animationName: nil,
                youTubeVideoId: nil,
                customViewId: nil
            ),
            TutorialItem(
                title: "Tool tips",
                message: "GodTools tips guide you as you help someone understand the gospel and encounter Jesus.",
                imageName: nil,
                animationName: nil,
                youTubeVideoId: nil,
                customViewId: nil
            ),
            TutorialItem(
                title: "Screen sharing",
                message: "You can now share your screen remotely so the other person can follow as you use a tool to discuss the gospel.",
                imageName: nil,
                animationName: nil,
                youTubeVideoId: nil,
                customViewId: nil
            ),
            TutorialItem(
                title: "Lessons",
                message: "In each GodTools lesson you learn something to help you have real conversations about God.",
                imageName: nil,
                animationName: nil,
                youTubeVideoId: nil,
                customViewId: nil
            ),
            TutorialItem(
                title: "Find this tutorial in the menu whenever you need it.",
                message: "",
                imageName: ImageCatalog.tutorialInMenuEnglish.name,
                animationName: nil,
                youTubeVideoId: nil,
                customViewId: nil
            )
        ]
        
        return tutorialItems
    }
    
    private func getNonEnglishTutorialItems() -> [TutorialItemType] {
        
        let tutorialItems: [TutorialItem] = [
            
            TutorialItem(
                title: localizationServices.stringForMainBundle(key: "tutorial.tutorialItem.0.title"),
                message: localizationServices.stringForMainBundle(key: "tutorial.tutorialItem.0.message"),
                imageName: nil,
                animationName: nil,
                youTubeVideoId: "ELRAmQxLqHE",
                customViewId: nil
            ),
            TutorialItem(
                title: localizationServices.stringForMainBundle(key: "tutorial.tutorialItem.1.title"),
                message: localizationServices.stringForMainBundle(key: "tutorial.tutorialItem.1.message"),
                imageName: ImageCatalog.tutorialToolNonEnglish.name,
                animationName: nil,
                youTubeVideoId: nil,
                customViewId: nil
            ),
            TutorialItem(
                title: localizationServices.stringForMainBundle(key: "tutorial.tutorialItem.2.title"),
                message: localizationServices.stringForMainBundle(key: "tutorial.tutorialItem.2.message"),
                imageName: "tutorial_people",
                animationName: nil,
                youTubeVideoId: nil,
                customViewId: nil
            ),
            TutorialItem(
                title: localizationServices.stringForMainBundle(key: "tutorial.tutorialItem.3.title"),
                message: "",
                imageName: ImageCatalog.tutorialInMenuNonEnglish.name,
                animationName: nil,
                youTubeVideoId: nil,
                customViewId: nil
            )
        ]
        
        return tutorialItems
    }
}
