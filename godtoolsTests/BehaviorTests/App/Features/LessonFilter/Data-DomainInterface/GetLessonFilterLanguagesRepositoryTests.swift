//
//  GetLessonFilterLanguagesRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/12/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct GetLessonFilterLanguagesRepositoryTests {
    
    private static let englishLessonsAvailableText: String = "lessons available"
    
    @Test(
        """
        Given: User is viewing the lesson language filter languages list.
        When: My app language is set.
        Then: I expect to see languages translated in my app language and translated in their original language.
        """
    )
    @MainActor func lessonFilterLanguagesAreTranslatedInMyAppLanguageAndTheirOriginalLanguage() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let lessonFilterLanguagesRepository: GetLessonFilterLanguagesRepository = Self.getLessonFilterLanguagesRepository()
        
        let appLanguageRussian: AppLanguageDomainModel = LanguageCodeDomainModel.russian.rawValue
        
        var languagesRef: [LessonFilterLanguageDomainModel] = Array()
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                lessonFilterLanguagesRepository
                    .getLessonFilterLanguagesPublisher(translatedInAppLanguage: appLanguageRussian)
                    .sink { (languages: [LessonFilterLanguageDomainModel]) in

                        confirmation()
                        
                        languagesRef = languages
                        
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    }
                    .store(in: &cancellables)
            }
        }
        
        let afrikaansLanguage: LessonFilterLanguageDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.afrikaans.rawValue})
        let czechLanguage: LessonFilterLanguageDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.czech.rawValue})
        let englishLanguage: LessonFilterLanguageDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.english.rawValue})
        let frenchLanguage: LessonFilterLanguageDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.french.rawValue})
        let spanishLanguage: LessonFilterLanguageDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.spanish.rawValue})

        #expect(afrikaansLanguage?.languageNameTranslatedInLanguage == "Afrikaans")
        #expect(afrikaansLanguage?.languageNameTranslatedInAppLanguage == "африкаанс")
        
        #expect(czechLanguage?.languageNameTranslatedInLanguage == "čeština")
        #expect(czechLanguage?.languageNameTranslatedInAppLanguage == "Чешский")
        
        #expect(englishLanguage?.languageNameTranslatedInLanguage == "English")
        #expect(englishLanguage?.languageNameTranslatedInAppLanguage == "Английский")
        
        #expect(frenchLanguage?.languageNameTranslatedInLanguage == "Français")
        #expect(frenchLanguage?.languageNameTranslatedInAppLanguage == "Французский")
        
        #expect(spanishLanguage?.languageNameTranslatedInLanguage == "Español")
        #expect(spanishLanguage?.languageNameTranslatedInAppLanguage == "испанский")
    }
    
    struct TestSortingArgument {
        let appLanguage: LanguageCodeDomainModel
        let expectedValue: [String]
    }
    
    @Test(
        """
        Given: User is viewing the lesson language filter languages list.
        When: My app language is set.
        Then: I expect to see languages sorted by the language name translated in my app language.
        """,
        arguments: [
            TestSortingArgument(appLanguage: .english, expectedValue: ["Afrikaans", "Czech", "English", "French", "Spanish"]),
            TestSortingArgument(appLanguage: .spanish, expectedValue: ["africaans", "Checo", "Español", "Francés", "Inglés"])
        ]
    )
    @MainActor func lessonFilterLanguagesAreSortedByLanguageNameTranslatedInMyAppLanguage(argument: TestSortingArgument) async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let lessonFilterLanguagesRepository: GetLessonFilterLanguagesRepository = Self.getLessonFilterLanguagesRepository()
                
        var languagesRef: [LessonFilterLanguageDomainModel] = Array()
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                lessonFilterLanguagesRepository
                    .getLessonFilterLanguagesPublisher(translatedInAppLanguage: argument.appLanguage.rawValue)
                    .sink { (languages: [LessonFilterLanguageDomainModel]) in
                        
                        confirmation()
                        
                        languagesRef = languages
                        
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    }
                    .store(in: &cancellables)
            }
        }
        
        #expect(languagesRef.map({$0.languageNameTranslatedInAppLanguage}) == argument.expectedValue)
    }
    
    @Test(
        """
        Given: User is viewing the lesson language filter languages list.
        When: My app language is set.
        Then: I expect to see the number of lessons available per language translated in my app language.
        """
    )
    @MainActor func lessonFilterLanguagesShowNumberOfLessonsPerLanguageTranslatedInMyAppLanguage() async {
        
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let lessonFilterLanguagesRepository: GetLessonFilterLanguagesRepository = Self.getLessonFilterLanguagesRepository()
        
        let appLanguageEnglish: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
        
        var languagesRef: [LessonFilterLanguageDomainModel] = Array()
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                lessonFilterLanguagesRepository
                    .getLessonFilterLanguagesPublisher(translatedInAppLanguage: appLanguageEnglish)
                    .sink { (languages: [LessonFilterLanguageDomainModel]) in

                        confirmation()
                        
                        languagesRef = languages
                        
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    }
                    .store(in: &cancellables)
            }
        }
        
        await confirmation(expectedCount: 1) { confirmation in
            
            lessonFilterLanguagesRepository
                .getLessonFilterLanguagesPublisher(translatedInAppLanguage: appLanguageEnglish)
                .sink { (languages: [LessonFilterLanguageDomainModel]) in

                    confirmation()
                    
                    languagesRef = languages
                }
                .store(in: &cancellables)
            
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }

        let afrikaansLanguage: LessonFilterLanguageDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.afrikaans.rawValue})
        let czechLanguage: LessonFilterLanguageDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.czech.rawValue})
        let englishLanguage: LessonFilterLanguageDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.english.rawValue})
        let frenchLanguage: LessonFilterLanguageDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.french.rawValue})
        let spanishLanguage: LessonFilterLanguageDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.spanish.rawValue})

        #expect(afrikaansLanguage?.lessonsAvailableText == "\(Self.englishLessonsAvailableText) 1")
        #expect(czechLanguage?.lessonsAvailableText == "\(Self.englishLessonsAvailableText) 1")
        #expect(englishLanguage?.lessonsAvailableText == "\(Self.englishLessonsAvailableText) 5")
        #expect(frenchLanguage?.lessonsAvailableText == "\(Self.englishLessonsAvailableText) 2")
        #expect(spanishLanguage?.lessonsAvailableText == "\(Self.englishLessonsAvailableText) 3")
    }
}

extension GetLessonFilterLanguagesRepositoryTests {
    
    private static func getLessonFilterLanguagesRepository() -> GetLessonFilterLanguagesRepository {
        
        let allLanguages: [RealmLanguage] = Self.getAllLanguages()
        
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
                        
        let realmDatabase: LegacyRealmDatabase = TestsInMemoryRealmDatabase(
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
        
        return getLessonFilterLanguagesRepository
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
        
        return MockRealmLanguage.createLanguage(
            language: languageCode,
            name: languageCode.rawValue + " Name",
            id: languageCode.rawValue
        )
    }
    
    private static func getLocalizationServices() -> MockLocalizationServices {
        
        let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.rawValue: [LessonFilterStringKeys.lessonsAvailableText.rawValue: Self.englishLessonsAvailableText]
        ]
        
        return MockLocalizationServices.createLanguageNamesLocalizationServices(
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
