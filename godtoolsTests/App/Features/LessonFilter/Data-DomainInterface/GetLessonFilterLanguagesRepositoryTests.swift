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
import RealmSwift

class GetLessonFilterLanguagesRepositoryTests: QuickSpec {
    
    override class func spec() {
                
        var cancellables: Set<AnyCancellable> = Set()
        
        let testsDiContainer = TestsDiContainer(
            realmDatabase: GetLessonFilterLanguagesRepositoryTests.getRealmDatabase()
        )
        
        let getLessonFilterLanguagesRepository = GetLessonFilterLanguagesRepository(
            resourcesRepository: testsDiContainer.dataLayer.getResourcesRepository(),
            languagesRepository: testsDiContainer.dataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: GetLessonFilterLanguagesRepositoryTests.getTranslatedLanguageName(),
            localizationServices: GetLessonFilterLanguagesRepositoryTests.getLocalizationServices()
        )
        
        describe("User is viewing the lessons language filter languages list.") {
         
            context("When my app language is spanish.") {
                
                it("I expect to see spanish lessons.") {

                    var languagesRef: [LessonLanguageFilterDomainModel] = Array()
                    var sinkCompleted: Bool = false

                    waitUntil { done in

                        getLessonFilterLanguagesRepository
                            .getLessonFilterLanguagesPublisher(translatedInAppLanguage: LanguageCodeDomainModel.spanish.rawValue)
                            .sink { (languages: [LessonLanguageFilterDomainModel]) in

                                guard !sinkCompleted else {
                                    return
                                }

                                sinkCompleted = true

                                languagesRef = languages

                                done()
                            }
                            .store(in: &cancellables)

                    }

                    expect(languagesRef.count).to(equal(4))
                }
            }
        }
    }
    
    private static func getRealmDatabase() -> RealmDatabase {
        
        let realmDatabase: RealmDatabase = TestsInMemoryRealmDatabase()

        let realmObjectsToAdd: [Object] = GetLessonFilterLanguagesRepositoryTests.getAllTools()
        
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
    
    private static func getAllTools() -> [RealmResource] {
        
        let arabicLanguage = RealmLanguage()
        arabicLanguage.id = "0"
        arabicLanguage.code = LanguageCodeDomainModel.arabic.rawValue
        arabicLanguage.name = "Arabic Name"
        
        let englishLanguage = RealmLanguage()
        englishLanguage.id = "1"
        englishLanguage.code = LanguageCodeDomainModel.english.rawValue
        englishLanguage.name = "English Name"
        
        let frenchLanguage = RealmLanguage()
        frenchLanguage.id = "2"
        frenchLanguage.code = LanguageCodeDomainModel.french.rawValue
        frenchLanguage.name = "French Name"
        
        let russianLanguage = RealmLanguage()
        russianLanguage.id = "3"
        russianLanguage.code = LanguageCodeDomainModel.russian.rawValue
        russianLanguage.name = "Russian Name"
        
        let spanishLanguage = RealmLanguage()
        spanishLanguage.id = "4"
        spanishLanguage.code = LanguageCodeDomainModel.spanish.rawValue
        spanishLanguage.name = "Spanish Name"
        
        let czechLanguage = RealmLanguage()
        czechLanguage.id = "5"
        czechLanguage.code = LanguageCodeDomainModel.czech.rawValue
        czechLanguage.name = "Czech Name"
        
        var allTracts: [RealmResource] = Array()
        var allLessons: [RealmResource] = Array()
        var allArticles: [RealmResource] = Array()
        
        for index in 0 ..< 20 {
            
            let tract: RealmResource = RealmResource()
            tract.id = "\(index)"
            tract.resourceType = ResourceType.tract.rawValue
            
            tract.addLanguage(language: englishLanguage)
            
            allTracts.append(tract)
        }
        
        for index in 20 ..< 30 {
            
            let lesson: RealmResource = RealmResource()
            lesson.id = "\(index)"
            lesson.resourceType = ResourceType.lesson.rawValue
            
            lesson.addLanguage(language: englishLanguage)
            
            allLessons.append(lesson)
        }
        
        for index in 30 ..< 35 {
            
            let article: RealmResource = RealmResource()
            article.id = "\(index)"
            article.resourceType = ResourceType.article.rawValue
            
            article.addLanguage(language: englishLanguage)
            
            allArticles.append(article)
        }
        
        return allTracts + allLessons + allArticles
    }
    
    private static func getLocalizationServices() -> MockLocalizationServices {
        
        let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.spanish.value: [
                LanguageCodeDomainModel.english.rawValue: "Inglés",
                LanguageCodeDomainModel.french.rawValue: "Francés",
                LanguageCodeDomainModel.spanish.rawValue: "Español",
                LanguageCodeDomainModel.russian.rawValue: "Ruso"
            ]
        ]
        
        return MockLocalizationServices(localizableStrings: localizableStrings)
    }
    
    private static func getLocaleLanguageName() -> MockLocaleLanguageName {
        
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
        
        return MockLocaleLanguageName(languageNames: languageNames)
    }
    
    private static func getTranslatedLanguageName() -> GetTranslatedLanguageName {
        
        let getTranslatedLanguageName = GetTranslatedLanguageName(
            localizationLanguageNameRepository: MockLocalizationLanguageNameRepository(localizationServices: GetLessonFilterLanguagesRepositoryTests.getLocalizationServices()),
            localeLanguageName: GetLessonFilterLanguagesRepositoryTests.getLocaleLanguageName(),
            localeRegionName: MockLocaleLanguageRegionName(regionNames: [:]),
            localeScriptName: MockLocaleLanguageScriptName(scriptNames: [:])
        )
        
        return getTranslatedLanguageName
    }
}
