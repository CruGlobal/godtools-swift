//
//  GetTutorialItemsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/22/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class GetTutorialItemsUseCase {
    
    private let localizationServices: LocalizationServices
    private let deviceLanguage: DeviceLanguageType
    
    required init(localizationServices: LocalizationServices, deviceLanguage: DeviceLanguageType) {
        
        self.localizationServices = localizationServices
        self.deviceLanguage = deviceLanguage
    }
    
    func getTutorialItems() -> [TutorialItemType] {
        
        return getNonEnglishTutorialItems()
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
                imageName: deviceLanguage.isEnglish ? ImageCatalog.tutorialToolEnglish.name : ImageCatalog.tutorialToolNonEnglish.name,
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
                imageName: deviceLanguage.isEnglish ? ImageCatalog.tutorialInMenuEnglish.name : ImageCatalog.tutorialInMenuNonEnglish.name,
                animationName: nil,
                youTubeVideoId: nil,
                customViewId: nil
            )
        ]
        
        return tutorialItems
    }
}
