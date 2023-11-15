//
//  GetTutorialRepository.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetTutorialRepository: GetTutorialRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getTutorialPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<[TutorialPageDomainModel], Never> {
        
        let isEnglish: Bool = translateInLanguage == LanguageCodeDomainModel.english.value
        
        let tutorialPages: [TutorialPageDomainModel] = isEnglish ? getEnglishTutorial(translateInLanguage: translateInLanguage) : getNonEnglishTutorial(translateInLanguage: translateInLanguage)
        
        return Just(tutorialPages)
            .eraseToAnyPublisher()
    }
    
    private func getEnglishTutorial(translateInLanguage: AppLanguageDomainModel) -> [TutorialPageDomainModel] {
        
        let localeId: String = translateInLanguage
        
        let tutorialPages = [
            
            TutorialPageDomainModel(
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "tutorial.lesson.title"),
                message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "tutorial.lesson.message"),
                videoId: nil,
                animatedResource: .mainBundleJsonFile(filename: "tutorial_lessons"),
                imageName: nil
            ),
            TutorialPageDomainModel(
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "tutorial.tool.title"),
                message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "tutorial.tool.message"),
                videoId: nil,
                animatedResource: nil,
                imageName: ImageCatalog.tutorialTool.rawValue
            ),
            TutorialPageDomainModel(
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "tutorial.toolTip.title"),
                message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "tutorial.toolTip.message"),
                videoId: nil,
                animatedResource: .mainBundleJsonFile(filename: "tutorial_tooltip"),
                imageName: nil
            ),
            TutorialPageDomainModel(
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "tutorial.screenShare.title"),
                message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "tutorial.screenShare.message"),
                videoId: nil,
                animatedResource: .mainBundleJsonFile(filename: "tutorial_screenshare"),
                imageName: nil
            ),
            TutorialPageDomainModel(
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "tutorial.findTutorial.title"),
                message: "",
                videoId: nil,
                animatedResource: nil,
                imageName: ImageCatalog.tutorialInMenuEnglish.name
            )
        ]
        
        return tutorialPages
    }
    
    private func getNonEnglishTutorial(translateInLanguage: AppLanguageDomainModel) -> [TutorialPageDomainModel] {
        
        let localeId: String = translateInLanguage
        
        let tutorialPages = [
            
            TutorialPageDomainModel(
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "tutorial.tutorialItem.0.title"),
                message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "tutorial.tutorialItem.0.message"),
                videoId: "ELRAmQxLqHE",
                animatedResource: nil,
                imageName: nil
            ),
            TutorialPageDomainModel(
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "tutorial.tutorialItem.1.title"),
                message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "tutorial.tutorialItem.1.message"),
                videoId: nil,
                animatedResource: nil,
                imageName: ImageCatalog.tutorialToolNonEnglish.name
            ),
            TutorialPageDomainModel(
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "tutorial.tutorialItem.2.title"),
                message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "tutorial.tutorialItem.2.message"),
                videoId: nil,
                animatedResource: nil,
                imageName: ImageCatalog.tutorialPeople.rawValue
            ),
            TutorialPageDomainModel(
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "tutorial.tutorialItem.3.title"),
                message: "",
                videoId: nil,
                animatedResource: nil,
                imageName: ImageCatalog.tutorialInMenuNonEnglish.name
            )
        ]
        
        return tutorialPages
    }
}
