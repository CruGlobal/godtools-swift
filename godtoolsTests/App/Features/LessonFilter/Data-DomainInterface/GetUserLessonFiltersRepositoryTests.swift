//
//  GetUserLessonFiltersRepositoryTests.swift
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
import RealmSwift

class GetUserLessonFiltersRepositoryTests: QuickSpec {
    
    override class func spec() {
        
        describe("User is viewing the language filter in the lessons list.") {
         
            context("When a lesson language filter hasn't been selected by the user.") {
                
                it("The lesson language filter should default to the current app language spanish when spanish lessons exist.") {
                    
                    let appLanguageSpanish: AppLanguageDomainModel = LanguageCodeDomainModel.spanish.rawValue
                    
                    let spanishLanguage = RealmLanguage()
                    spanishLanguage.id = "0"
                    spanishLanguage.code = LanguageCodeDomainModel.spanish.rawValue
                    spanishLanguage.name = "Spanish Name"
                    
                    let spanishLesson_0 = RealmResource()
                    spanishLesson_0.id = "es-lesson-0"
                    spanishLesson_0.resourceType = ResourceType.lesson.rawValue
                    spanishLesson_0.addLanguage(language: spanishLanguage)
                    
                    let realmObjectsToAdd: [Object] = [spanishLanguage, spanishLesson_0]
                    
                    let testsDiContainer = TestsDiContainer(
                        realmDatabase: GetUserLessonFiltersRepositoryTests.getRealmDatabase(addRealmObjects: realmObjectsToAdd)
                    )
                    
                    let getUserLessonFiltersRepository = GetUserLessonFiltersRepository(
                        userLessonFiltersRepository: GetUserLessonFiltersRepositoryTests.getUserLessonFiltersRepository(testsDiContainer: testsDiContainer),
                        getLessonFilterLanguagesRepository: GetUserLessonFiltersRepositoryTests.getLessonFilterLanguagesRepository(testsDiContainer: testsDiContainer)
                    )
                    
                    var lessonLanguageFilterRef: LessonLanguageFilterDomainModel?
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = getUserLessonFiltersRepository
                            .getUserLessonLanguageFilterPublisher(translatedInAppLanguage: appLanguageSpanish)
                            .sink { (lessonLanguageFilter: LessonLanguageFilterDomainModel?) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                lessonLanguageFilterRef = lessonLanguageFilter
                                
                                done()
                            }
                        
                    }
                    
                    expect(lessonLanguageFilterRef?.languageName).to(equal("Español"))
                    expect(lessonLanguageFilterRef?.translatedName).to(equal("Español"))
                }
            }
            
            context("When a lesson language filter hasn't been selected by the user.") {
                
                it("The lesson language filter should default to the current app language french even when there are no lessons in french.") {
                    
                    let appLanguageRussian: AppLanguageDomainModel = LanguageCodeDomainModel.russian.rawValue
                    
                    let spanishLanguage = RealmLanguage()
                    spanishLanguage.id = "0"
                    spanishLanguage.code = LanguageCodeDomainModel.spanish.rawValue
                    spanishLanguage.name = "Spanish Name"
                    
                    let frenchLanguage = RealmLanguage()
                    frenchLanguage.id = "1"
                    frenchLanguage.code = LanguageCodeDomainModel.french.rawValue
                    frenchLanguage.name = "French Name"
                    
                    let spanishLesson_0 = RealmResource()
                    spanishLesson_0.id = "es-lesson-0"
                    spanishLesson_0.resourceType = ResourceType.lesson.rawValue
                    spanishLesson_0.addLanguage(language: spanishLanguage)
                    
                    let frenchTract_0 = RealmResource()
                    frenchTract_0.id = "fr-lesson-0"
                    frenchTract_0.resourceType = ResourceType.tract.rawValue
                    frenchTract_0.addLanguage(language: frenchLanguage)
                    
                    let realmObjectsToAdd: [Object] = [spanishLanguage, frenchLanguage, spanishLesson_0, frenchTract_0]
                    
                    let testsDiContainer = TestsDiContainer(
                        realmDatabase: GetUserLessonFiltersRepositoryTests.getRealmDatabase(addRealmObjects: realmObjectsToAdd)
                    )
                    
                    let getUserLessonFiltersRepository = GetUserLessonFiltersRepository(
                        userLessonFiltersRepository: GetUserLessonFiltersRepositoryTests.getUserLessonFiltersRepository(testsDiContainer: testsDiContainer),
                        getLessonFilterLanguagesRepository: GetUserLessonFiltersRepositoryTests.getLessonFilterLanguagesRepository(testsDiContainer: testsDiContainer)
                    )
                    
                    var lessonLanguageFilterRef: LessonLanguageFilterDomainModel?
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = getUserLessonFiltersRepository
                            .getUserLessonLanguageFilterPublisher(translatedInAppLanguage: appLanguageRussian)
                            .sink { (lessonLanguageFilter: LessonLanguageFilterDomainModel?) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                lessonLanguageFilterRef = lessonLanguageFilter
                                
                                done()
                            }
                        
                    }
                    
                    expect(lessonLanguageFilterRef?.languageName).to(equal("Français"))
                    expect(lessonLanguageFilterRef?.translatedName).to(equal("Français"))
                }
            }
        }
    }
    
    private static func getRealmDatabase(addRealmObjects: [Object]) -> RealmDatabase {
        
        let realmDatabase: RealmDatabase = TestsInMemoryRealmDatabase()
        
        let realmObjectsToAdd: [Object] = addRealmObjects
        
        let realm: Realm = realmDatabase.openRealm()
                    
        do {
            try realm.write {
                realm.add(realmObjectsToAdd, update: .all)
            }
        }
        catch _ {
            
        }
        
        return realmDatabase
    }
    
    private static func getUserLessonFiltersRepository(testsDiContainer: TestsDiContainer) -> UserLessonFiltersRepository {
        
        return testsDiContainer.feature.lessonFilter.dataLayer.getUserLessonFiltersRepository()
    }
    
    private static func getLessonFilterLanguagesRepository(testsDiContainer: TestsDiContainer) -> GetLessonFilterLanguagesRepository {
        
        return GetLessonFilterLanguagesRepository(
            resourcesRepository: testsDiContainer.dataLayer.getResourcesRepository(),
            languagesRepository: testsDiContainer.dataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: GetUserLessonFiltersRepositoryTests.getTranslatedLanguageName(),
            localizationServices: GetUserLessonFiltersRepositoryTests.getLocalizationServices()
        )
    }
    
    private static func getLocalizationServices() -> MockLocalizationServices {
        
        let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.spanish.value: [
                LanguageCodeDomainModel.french.rawValue: "Francés"
            ]
        ]
        
        return MockLocalizationServices(localizableStrings: localizableStrings)
    }
    
    private static func getLocaleLanguageName() -> MockLocaleLanguageName {
        
        let languageNames: [MockLocaleLanguageName.LanguageCode: [MockLocaleLanguageName.TranslateInLocaleId: MockLocaleLanguageName.LanguageName]] = [
            LanguageCodeDomainModel.english.rawValue: [
                LanguageCodeDomainModel.english.rawValue: "English",
                LanguageCodeDomainModel.french.rawValue: "Anglais",
                LanguageCodeDomainModel.portuguese.rawValue: "Inglês",
                LanguageCodeDomainModel.spanish.rawValue: "Inglés",
                LanguageCodeDomainModel.russian.rawValue: "Английский"
            ],
            LanguageCodeDomainModel.french.rawValue: [
                LanguageCodeDomainModel.english.rawValue: "French",
                LanguageCodeDomainModel.french.rawValue: "Français",
                LanguageCodeDomainModel.portuguese.rawValue: "Francês",
                LanguageCodeDomainModel.spanish.rawValue: "Francés",
                LanguageCodeDomainModel.russian.rawValue: "Французский"
            ],
            LanguageCodeDomainModel.spanish.rawValue: [
                LanguageCodeDomainModel.english.rawValue: "Spanish",
                LanguageCodeDomainModel.french.rawValue: "Espagnol",
                LanguageCodeDomainModel.portuguese.rawValue: "Espanhol",
                LanguageCodeDomainModel.spanish.rawValue: "Español",
                LanguageCodeDomainModel.russian.rawValue: "испанский"
            ]
        ]
        
        return MockLocaleLanguageName(languageNames: languageNames)
    }
    
    private static func getTranslatedLanguageName() -> GetTranslatedLanguageName {
        
        let getTranslatedLanguageName = GetTranslatedLanguageName(
            localizationLanguageNameRepository: MockLocalizationLanguageNameRepository(localizationServices: GetUserLessonFiltersRepositoryTests.getLocalizationServices()),
            localeLanguageName: GetUserLessonFiltersRepositoryTests.getLocaleLanguageName(),
            localeRegionName: MockLocaleLanguageRegionName(regionNames: [:]),
            localeScriptName: MockLocaleLanguageScriptName(scriptNames: [:])
        )
        
        return getTranslatedLanguageName
    }
}
