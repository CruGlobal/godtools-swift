//
//  GetLessonFilterLanguagesRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/12/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class GetLessonFilterLanguagesRepositoryTests: QuickSpec {
    
    override class func spec() {
        
        let testsDiContainer = TestsDiContainer()
        
        let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.spanish.value: [
                LanguageCodeDomainModel.english.rawValue: "Inglés",
                LanguageCodeDomainModel.french.rawValue: "Francés",
                LanguageCodeDomainModel.spanish.rawValue: "Español",
                LanguageCodeDomainModel.russian.rawValue: "Ruso"
            ]
        ]
        
        let languageNames: [MockLocaleLanguageName.LanguageCode: [MockLocaleLanguageName.TranslateInLocaleId: MockLocaleLanguageName.LanguageName]] = [
            LanguageCodeDomainModel.english.rawValue: [
                LanguageCodeDomainModel.english.rawValue: "English",
                LanguageCodeDomainModel.portuguese.rawValue: "Inglês",
                LanguageCodeDomainModel.spanish.rawValue: "Inglés",
                LanguageCodeDomainModel.russian.rawValue: "Английский"
            ],
            LanguageCodeDomainModel.french.rawValue: [
                LanguageCodeDomainModel.czech.rawValue: "francouzština",
                LanguageCodeDomainModel.english.rawValue: "French",
                LanguageCodeDomainModel.portuguese.rawValue: "Francês",
                LanguageCodeDomainModel.spanish.rawValue: "Francés",
                LanguageCodeDomainModel.russian.rawValue: "Французский"
            ],
            LanguageCodeDomainModel.spanish.rawValue: [
                LanguageCodeDomainModel.english.rawValue: "Spanish",
                LanguageCodeDomainModel.portuguese.rawValue: "Espanhol",
                LanguageCodeDomainModel.spanish.rawValue: "Español",
                LanguageCodeDomainModel.russian.rawValue: "испанский"
            ]
        ]
                
        let getTranslatedLanguageName = GetTranslatedLanguageName(
            localizationLanguageNameRepository: MockLocalizationLanguageNameRepository(localizationServices: MockLocalizationServices(localizableStrings: localizableStrings)),
            localeLanguageName: MockLocaleLanguageName(languageNames: languageNames),
            localeRegionName: MockLocaleLanguageRegionName(regionNames: [:]),
            localeScriptName: MockLocaleLanguageScriptName(scriptNames: [:])
        )
        
        let getLessonFilterLanguagesRepository = GetLessonFilterLanguagesRepository(
            resourcesRepository: testsDiContainer.dataLayer.getResourcesRepository(),
            languagesRepository: testsDiContainer.dataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: getTranslatedLanguageName,
            localizationServices: MockLocalizationServices(localizableStrings: [:])
        )
        
        describe("User is viewing the lessons language filter languages list.") {
         
            context("When my app language is spanish.") {
                
                let getOnboardingIsAvailable = GetOnboardingTutorialIsAvailable(
                    launchCountRepository: MockLaunchCountRepository(launchCount: 1),
                    onboardingTutorialViewedRepository: MockOnboardingTutorialViewedRepository(tutorialViewed: false)
                )

                it("I expect to see the language name translated in spanish.") {

                    var languagesRef: [LessonLanguageFilterDomainModel] = Array()
                    var sinkCompleted: Bool = false

                    waitUntil { done in

                        _ = getLessonFilterLanguagesRepository
                            .getLessonFilterLanguagesPublisher(translatedInAppLanguage: LanguageCodeDomainModel.spanish.rawValue)
                            .sink { (languages: [LessonLanguageFilterDomainModel]) in

                                guard !sinkCompleted else {
                                    return
                                }

                                sinkCompleted = true

                                languagesRef = languages

                                done()
                            }

                    }

                    expect(lessonLanguageFilterRef?.translatedName).to(equal(true))
                }
            }
        }
    }
}
