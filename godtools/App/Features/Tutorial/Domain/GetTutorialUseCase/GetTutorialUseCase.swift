//
//  GetTutorialUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/22/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import Lottie

class GetTutorialUseCase {
    
    private let localizationServices: LocalizationServices
    private let deviceLanguage: DeviceLanguageType
    
    required init(localizationServices: LocalizationServices, deviceLanguage: DeviceLanguageType) {
        
        self.localizationServices = localizationServices
        self.deviceLanguage = deviceLanguage
    }
    
    func getTutorial() -> TutorialModel {
        
        let tutorialItems: [TutorialItemType]
        let defaultContinueButtonTitle: String = localizationServices.stringForMainBundle(key: "tutorial.continueButton.title.continue")
        let lastPageContinueButtonTitle: String
        
        if deviceLanguage.isEnglish {
            
            tutorialItems = getEnglishTutorialItems()
            lastPageContinueButtonTitle = localizationServices.stringForMainBundle(key: "tutorial.continueButton.title.closeTutorial")
        }
        else {
            
            tutorialItems = getNonEnglishTutorialItems()
            lastPageContinueButtonTitle = localizationServices.stringForMainBundle(key: "tutorial.continueButton.title.startUsingGodTools")
        }
        
        return TutorialModel(
            tutorialItems: tutorialItems,
            defaultContinueButtonTitle: defaultContinueButtonTitle,
            lastPageContinueButtonTitle: lastPageContinueButtonTitle
        )
    }
    
    private func getEnglishTutorialItems() -> [TutorialItemType] {
        
        let tutorialItems: [TutorialItem] = [
            
            TutorialItem(
                title: localizationServices.stringForMainBundle(key: "tutorial.lesson.title"),
                message: localizationServices.stringForMainBundle(key: "tutorial.lesson.message"),
                imageName: nil,
                animationName: "tutorial_lessons",
                youTubeVideoId: nil,
                customViewId: nil
            ),
            TutorialItem(
                title: localizationServices.stringForMainBundle(key: "tutorial.tool.title"),
                message: localizationServices.stringForMainBundle(key: "tutorial.tool.message"),
                imageName: ImageCatalog.tutorialTool.rawValue,
                animationName: nil,
                youTubeVideoId: nil,
                customViewId: nil
            ),
            TutorialItem(
                title: localizationServices.stringForMainBundle(key: "tutorial.toolTip.title"),
                message: localizationServices.stringForMainBundle(key: "tutorial.toolTip.message"),
                imageName: nil,
                animationName: "tutorial_tooltip",
                youTubeVideoId: nil,
                customViewId: nil
            ),
            TutorialItem(
                title: localizationServices.stringForMainBundle(key: "tutorial.screenShare.title"),
                message: localizationServices.stringForMainBundle(key: "tutorial.screenShare.message"),
                imageName: nil,
                animationName: "tutorial_screenshare",
                youTubeVideoId: nil,
                customViewId: nil
            ),
            TutorialItem(
                title: localizationServices.stringForMainBundle(key: "tutorial.findTutorial.title"),
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
                imageName: ImageCatalog.tutorialPeople.rawValue,
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
