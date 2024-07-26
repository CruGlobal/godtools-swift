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
        
        describe("User is viewing the lessons list.") {
         
            context("When my lesson language filter is spanish.") {
                
                let appLanguageSpanish: AppLanguageDomainModel = LanguageCodeDomainModel.spanish.rawValue
                
                let realmDatabase: RealmDatabase = TestsInMemoryRealmDatabase()
                
                let allLanguages: [RealmLanguage] = GetLessonFilterLanguagesRepositoryTests.getAllLanguages()
                
                let tracts = [
                    MockResourcesRepository.getTract(addLanguages: [.english, .arabic, .czech, .spanish], fromLanguages: allLanguages),
                    MockResourcesRepository.getTract(addLanguages: [.spanish], fromLanguages: allLanguages),
                    MockResourcesRepository.getTract(addLanguages: [.afrikaans, .arabic], fromLanguages: allLanguages),
                    MockResourcesRepository.getTract(addLanguages: [.czech, .french, .hebrew], fromLanguages: allLanguages)
                ]
                
                let lessons = [
                    MockResourcesRepository.getLesson(addLanguages: [.english], fromLanguages: allLanguages, id: "0"),
                    MockResourcesRepository.getLesson(addLanguages: [.english, .spanish], fromLanguages: allLanguages, id: "1"),
                    MockResourcesRepository.getLesson(addLanguages: [.afrikaans, .spanish], fromLanguages: allLanguages, id: "2"),
                    MockResourcesRepository.getLesson(addLanguages: [.czech, .french], fromLanguages: allLanguages, id: "3")
                ]
                
                let realmObjectsToAdd: [Object] = allLanguages + tracts + lessons
                
                let realm: Realm = realmDatabase.openRealm()
                            
                do {
                    try realm.write {
                        realm.add(realmObjectsToAdd, update: .all)
                    }
                }
                catch _ {
                    
                }
                
                let testsDiContainer = TestsDiContainer(realmDatabase: realmDatabase)
                
                let getLessonFilterLanguagesRepository = GetLessonFilterLanguagesRepository(
                    resourcesRepository: testsDiContainer.dataLayer.getResourcesRepository(),
                    languagesRepository: testsDiContainer.dataLayer.getLanguagesRepository(),
                    getTranslatedLanguageName: GetLessonFilterLanguagesRepositoryTests.getTranslatedLanguageName(),
                    localizationServices: GetLessonFilterLanguagesRepositoryTests.getLocalizationServices()
                )
                
                it("I expect to see lesson 1 and lesson 2 and I should not see lesson 0 and lesson 3.") {

                    var languagesRef: [LessonLanguageFilterDomainModel] = Array()
                    var sinkCompleted: Bool = false

                    waitUntil { done in

                        getLessonFilterLanguagesRepository
                            .getLessonFilterLanguagesPublisher(translatedInAppLanguage: appLanguageSpanish)
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

                    expect(languagesRef.count).to(equal(0))
                }
            }
        }
    }
    
    private static func getAllLanguages() -> [RealmLanguage] {
        
        return [
            MockLanguagesRepository.getLanguage(language: .arabic, name: "arabic Name"),
            MockLanguagesRepository.getLanguage(language: .english, name: "english Name"),
            MockLanguagesRepository.getLanguage(language: .french, name: "french Name"),
            MockLanguagesRepository.getLanguage(language: .russian, name: "russian Name"),
            MockLanguagesRepository.getLanguage(language: .spanish, name: "spanish Name"),
            MockLanguagesRepository.getLanguage(language: .czech, name: "czech Name"),
            MockLanguagesRepository.getLanguage(language: .hebrew, name: "hebrew Name")
        ]
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
    
    private static func getTranslatedLanguageName() -> GetTranslatedLanguageName {
        
        let getTranslatedLanguageName = GetTranslatedLanguageName(
            localizationLanguageNameRepository: MockLocalizationLanguageNameRepository(localizationServices: GetLessonFilterLanguagesRepositoryTests.getLocalizationServices()),
            localeLanguageName: MockLocaleLanguageName.defaultMockLocaleLanguageName(),
            localeRegionName: MockLocaleLanguageRegionName(regionNames: [:]),
            localeScriptName: MockLocaleLanguageScriptName(scriptNames: [:])
        )
        
        return getTranslatedLanguageName
    }
}
