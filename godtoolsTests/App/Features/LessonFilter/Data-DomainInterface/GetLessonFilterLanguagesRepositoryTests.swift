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
    
    private static let englishLessonsAvailableText: String = "lessons available"
    
    override class func spec() {
                
        var cancellables: Set<AnyCancellable> = Set()
        
        let allLanguages: [RealmLanguage] = GetLessonFilterLanguagesRepositoryTests.getAllLanguages()
        
        let tracts = [
            MockRealmResource.createTract(addLanguages: [.english, .arabic, .czech, .spanish], fromLanguages: allLanguages),
            MockRealmResource.createTract(addLanguages: [.spanish], fromLanguages: allLanguages),
            MockRealmResource.createTract(addLanguages: [.afrikaans, .arabic], fromLanguages: allLanguages),
            MockRealmResource.createTract(addLanguages: [.czech, .french, .hebrew], fromLanguages: allLanguages),
            MockRealmResource.createTract(addLanguages: [.english, .chinese], fromLanguages: allLanguages),
            MockRealmResource.createTract(addLanguages: [.english, .russian], fromLanguages: allLanguages),
            MockRealmResource.createTract(addLanguages: [.english, .portuguese], fromLanguages: allLanguages),
            MockRealmResource.createTract(addLanguages: [.english, .latvian], fromLanguages: allLanguages)
        ]
        
        let lessons = [
            MockRealmResource.createLesson(addLanguages: [.english], fromLanguages: allLanguages),
            MockRealmResource.createLesson(addLanguages: [.english, .spanish], fromLanguages: allLanguages),
            MockRealmResource.createLesson(addLanguages: [.afrikaans, .spanish], fromLanguages: allLanguages),
            MockRealmResource.createLesson(addLanguages: [.czech, .french], fromLanguages: allLanguages),
            MockRealmResource.createLesson(addLanguages: [.english, .french, .spanish], fromLanguages: allLanguages),
            MockRealmResource.createLesson(addLanguages: [.english], fromLanguages: allLanguages),
            MockRealmResource.createLesson(addLanguages: [.english], fromLanguages: allLanguages)
        ]
                        
        let realmDatabase: RealmDatabase = TestsInMemoryRealmDatabase(
            addObjectsToDatabase: allLanguages + tracts + lessons
        )
        
        let testsDiContainer = TestsDiContainer(realmDatabase: realmDatabase)
        
        let getLessonFilterLanguagesRepository = GetLessonFilterLanguagesRepository(
            resourcesRepository: testsDiContainer.dataLayer.getResourcesRepository(),
            languagesRepository: testsDiContainer.dataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: Self.getTranslatedLanguageName(),
            localizationServices: Self.getLocalizationServices(),
            stringWithLocaleCount: Self.getStringWithLocaleCount()
        )
        
        describe("User is viewing the lesson language filter languages list.") {
         
            context("When my app language is russian.") {
                
                let appLanguageRussian: AppLanguageDomainModel = LanguageCodeDomainModel.russian.rawValue
                
                it("I expect to see languages translated in my app language russian and translated in their original language.") {

                    var languagesRef: [LessonLanguageFilterDomainModel] = Array()
                    var sinkCompleted: Bool = false

                    waitUntil { done in

                        getLessonFilterLanguagesRepository
                            .getLessonFilterLanguagesPublisher(translatedInAppLanguage: appLanguageRussian)
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
                    
                    let afrikaansLanguage: LessonLanguageFilterDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.afrikaans.rawValue})
                    let czechLanguage: LessonLanguageFilterDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.czech.rawValue})
                    let englishLanguage: LessonLanguageFilterDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.english.rawValue})
                    let frenchLanguage: LessonLanguageFilterDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.french.rawValue})
                    let spanishLanguage: LessonLanguageFilterDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.spanish.rawValue})

                    expect(afrikaansLanguage?.languageName).to(equal("Afrikaans"))
                    expect(afrikaansLanguage?.translatedName).to(equal("африкаанс"))
                    
                    expect(czechLanguage?.languageName).to(equal("čeština"))
                    expect(czechLanguage?.translatedName).to(equal("Чешский"))
                    
                    expect(englishLanguage?.languageName).to(equal("English"))
                    expect(englishLanguage?.translatedName).to(equal("Английский"))
                    
                    expect(frenchLanguage?.languageName).to(equal("Français"))
                    expect(frenchLanguage?.translatedName).to(equal("Французский"))
                    
                    expect(spanishLanguage?.languageName).to(equal("Español"))
                    expect(spanishLanguage?.translatedName).to(equal("испанский"))
                }
            }
            
            context("When my app language is english.") {
                
                let appLanguageEnglish: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
                
                it("I expect to see languages sorted by language name translated in app language english.") {

                    var languagesRef: [LessonLanguageFilterDomainModel] = Array()
                    var sinkCompleted: Bool = false

                    waitUntil { done in

                        getLessonFilterLanguagesRepository
                            .getLessonFilterLanguagesPublisher(translatedInAppLanguage: appLanguageEnglish)
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

                    expect(languagesRef[0].translatedName).to(equal("Afrikaans"))
                    expect(languagesRef[1].translatedName).to(equal("Czech"))
                    expect(languagesRef[2].translatedName).to(equal("English"))
                    expect(languagesRef[3].translatedName).to(equal("French"))
                    expect(languagesRef[4].translatedName).to(equal("Spanish"))
                }
            }
            
            context("When my app language is russian.") {
                
                let appLanguageSpanish: AppLanguageDomainModel = LanguageCodeDomainModel.spanish.rawValue
                
                it("I expect to see languages sorted by language name translated in app language spanish.") {

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

                    expect(languagesRef[0].translatedName).to(equal("africaans"))
                    expect(languagesRef[1].translatedName).to(equal("Checo"))
                    expect(languagesRef[2].translatedName).to(equal("Español"))
                    expect(languagesRef[3].translatedName).to(equal("Francés"))
                    expect(languagesRef[4].translatedName).to(equal("Inglés"))
                }
            }
            
            context("When my app language is english.") {
                
                let appLanguageEnglish: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
                
                it("I expect to see the number of lessons available per language translated in my app language english.") {

                    var languagesRef: [LessonLanguageFilterDomainModel] = Array()
                    var sinkCompleted: Bool = false

                    waitUntil { done in

                        getLessonFilterLanguagesRepository
                            .getLessonFilterLanguagesPublisher(translatedInAppLanguage: appLanguageEnglish)
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
                    
                    let afrikaansLanguage: LessonLanguageFilterDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.afrikaans.rawValue})
                    let czechLanguage: LessonLanguageFilterDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.czech.rawValue})
                    let englishLanguage: LessonLanguageFilterDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.english.rawValue})
                    let frenchLanguage: LessonLanguageFilterDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.french.rawValue})
                    let spanishLanguage: LessonLanguageFilterDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.spanish.rawValue})

                    expect(afrikaansLanguage?.lessonsAvailableText).to(equal("\(Self.englishLessonsAvailableText) 1"))
                    expect(czechLanguage?.lessonsAvailableText).to(equal("\(Self.englishLessonsAvailableText) 1"))
                    expect(englishLanguage?.lessonsAvailableText).to(equal("\(Self.englishLessonsAvailableText) 5"))
                    expect(frenchLanguage?.lessonsAvailableText).to(equal("\(Self.englishLessonsAvailableText) 2"))
                    expect(spanishLanguage?.lessonsAvailableText).to(equal("\(Self.englishLessonsAvailableText) 3"))
                }
            }
        }
    }
    
    private static func getAllLanguages() -> [RealmLanguage] {
        
        return [
            getRealmLanguage(languageCode: .afrikaans),
            getRealmLanguage(languageCode: .arabic),
            getRealmLanguage(languageCode: .chinese),
            getRealmLanguage(languageCode: .czech),
            getRealmLanguage(languageCode: .english),
            getRealmLanguage(languageCode: .french),
            getRealmLanguage(languageCode: .hebrew),
            getRealmLanguage(languageCode: .latvian),
            getRealmLanguage(languageCode: .portuguese),
            getRealmLanguage(languageCode: .russian),
            getRealmLanguage(languageCode: .spanish),
            getRealmLanguage(languageCode: .vietnamese)
        ]
    }
    
    private static func getRealmLanguage(languageCode: LanguageCodeDomainModel) -> RealmLanguage {
        
        return MockRealmLanguage.getLanguage(language: languageCode, name: languageCode.rawValue + " Name", id: languageCode.rawValue)
    }
    
    private static func getLocalizationServices() -> MockLocalizationServices {
        
        let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.rawValue: [LessonFilterStringKeys.lessonsAvailableText.rawValue: Self.englishLessonsAvailableText]
        ]
        
        return MockLocalizationServices.languageNamesLocalizationServices(
            addAdditionalLocalizableStrings: localizableStrings
        )
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
    
    private static func getStringWithLocaleCount() -> StringWithLocaleCountInterface {
        
        return MockStringWithLocaleCount()
    }
}
