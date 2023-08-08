//
//  GetTutorialUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/22/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import Combine

class GetTutorialUseCase {
    
    private let localizationServices: LocalizationServices
    private let getDeviceLanguageUseCase: GetDeviceLanguageUseCase
    
    init(localizationServices: LocalizationServices, getDeviceLanguageUseCase: GetDeviceLanguageUseCase) {
        
        self.localizationServices = localizationServices
        self.getDeviceLanguageUseCase = getDeviceLanguageUseCase
    }
    
    func getTutorialPublisher() -> AnyPublisher<TutorialDomainModel, Never> {
        
        return Just(getTutorialValue())
            .eraseToAnyPublisher()
    }
    
    func getTutorialValue() -> TutorialDomainModel {
        
        let tutorialItems: [TutorialItemDomainModel]
        let defaultContinueButtonTitle: String = localizationServices.stringForMainBundle(key: "tutorial.continueButton.title.continue")
        let lastPageContinueButtonTitle: String
        
        if getDeviceLanguageUseCase.getDeviceLanguage().localeLanguageCode == LanguageCodes.english {
            
            tutorialItems = getEnglishTutorialItems()
            lastPageContinueButtonTitle = localizationServices.stringForMainBundle(key: "tutorial.continueButton.title.closeTutorial")
        }
        else {
            
            tutorialItems = getNonEnglishTutorialItems()
            lastPageContinueButtonTitle = localizationServices.stringForMainBundle(key: "tutorial.continueButton.title.startUsingGodTools")
        }
        
        return TutorialDomainModel(
            tutorialItems: tutorialItems,
            defaultContinueButtonTitle: defaultContinueButtonTitle,
            lastPageContinueButtonTitle: lastPageContinueButtonTitle
        )
    }
    
    private func getEnglishTutorialItems() -> [TutorialItemDomainModel] {
        
        let tutorialItems: [TutorialItemDomainModel] = [
            
            TutorialItemDomainModel(
                title: localizationServices.stringForMainBundle(key: "tutorial.lesson.title"),
                message: localizationServices.stringForMainBundle(key: "tutorial.lesson.message"),
                imageName: nil,
                animationName: "tutorial_lessons",
                youTubeVideoId: nil
            ),
            TutorialItemDomainModel(
                title: localizationServices.stringForMainBundle(key: "tutorial.tool.title"),
                message: localizationServices.stringForMainBundle(key: "tutorial.tool.message"),
                imageName: ImageCatalog.tutorialTool.rawValue,
                animationName: nil,
                youTubeVideoId: nil
            ),
            TutorialItemDomainModel(
                title: localizationServices.stringForMainBundle(key: "tutorial.toolTip.title"),
                message: localizationServices.stringForMainBundle(key: "tutorial.toolTip.message"),
                imageName: nil,
                animationName: "tutorial_tooltip",
                youTubeVideoId: nil
            ),
            TutorialItemDomainModel(
                title: localizationServices.stringForMainBundle(key: "tutorial.screenShare.title"),
                message: localizationServices.stringForMainBundle(key: "tutorial.screenShare.message"),
                imageName: nil,
                animationName: "tutorial_screenshare",
                youTubeVideoId: nil
            ),
            TutorialItemDomainModel(
                title: localizationServices.stringForMainBundle(key: "tutorial.findTutorial.title"),
                message: "",
                imageName: ImageCatalog.tutorialInMenuEnglish.name,
                animationName: nil,
                youTubeVideoId: nil
            )
        ]
        
        return tutorialItems
    }
    
    private func getNonEnglishTutorialItems() -> [TutorialItemDomainModel] {
        
        let tutorialItems: [TutorialItemDomainModel] = [
            
            TutorialItemDomainModel(
                title: localizationServices.stringForMainBundle(key: "tutorial.tutorialItem.0.title"),
                message: localizationServices.stringForMainBundle(key: "tutorial.tutorialItem.0.message"),
                imageName: nil,
                animationName: nil,
                youTubeVideoId: "ELRAmQxLqHE"
            ),
            TutorialItemDomainModel(
                title: localizationServices.stringForMainBundle(key: "tutorial.tutorialItem.1.title"),
                message: localizationServices.stringForMainBundle(key: "tutorial.tutorialItem.1.message"),
                imageName: ImageCatalog.tutorialToolNonEnglish.name,
                animationName: nil,
                youTubeVideoId: nil
            ),
            TutorialItemDomainModel(
                title: localizationServices.stringForMainBundle(key: "tutorial.tutorialItem.2.title"),
                message: localizationServices.stringForMainBundle(key: "tutorial.tutorialItem.2.message"),
                imageName: ImageCatalog.tutorialPeople.rawValue,
                animationName: nil,
                youTubeVideoId: nil
            ),
            TutorialItemDomainModel(
                title: localizationServices.stringForMainBundle(key: "tutorial.tutorialItem.3.title"),
                message: "",
                imageName: ImageCatalog.tutorialInMenuNonEnglish.name,
                animationName: nil,
                youTubeVideoId: nil
            )
        ]
        
        return tutorialItems
    }
}
