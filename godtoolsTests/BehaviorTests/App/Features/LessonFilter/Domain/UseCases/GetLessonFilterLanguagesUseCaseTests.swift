//
//  GetLessonFilterLanguagesUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/12/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine
import RepositorySync

@Suite(.serialized)
struct GetLessonFilterLanguagesUseCaseTests {
    
    private let englishLessonsAvailableText: String = "lessons available"
    
    @Test(
        """
        Given: User is viewing the lesson language filter languages list.
        When: My app language is set.
        Then: I expect to see languages translated in my app language and translated in their original language.
        """
    )
    @MainActor func lessonFilterLanguagesAreTranslatedInMyAppLanguageAndTheirOriginalLanguage() async throws {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let getLessonFilterLanguagesUseCase: GetLessonFilterLanguagesUseCase = try getLessonFilterLanguagesUseCase()
        
        let appLanguageRussian: AppLanguageDomainModel = LanguageCodeDomainModel.russian.rawValue
        
        var languagesRef: [LessonFilterLanguageDomainModel] = Array()
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.defaultTestSleep()
                    continuation.resume(returning: ())
                }
                
                getLessonFilterLanguagesUseCase
                    .execute(appLanguage: appLanguageRussian)
                    .sink(receiveCompletion: { _ in
                        
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                        
                    }, receiveValue: { (languages: [LessonFilterLanguageDomainModel]) in
                        
                        languagesRef = languages
                        
                        confirmation()
                    })
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
    @MainActor func lessonFilterLanguagesAreSortedByLanguageNameTranslatedInMyAppLanguage(argument: TestSortingArgument) async throws {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let getLessonFilterLanguagesUseCase: GetLessonFilterLanguagesUseCase = try getLessonFilterLanguagesUseCase()
                
        var languagesRef: [LessonFilterLanguageDomainModel] = Array()
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.defaultTestSleep()
                    continuation.resume(returning: ())
                }
                
                getLessonFilterLanguagesUseCase
                    .execute(appLanguage: argument.appLanguage.rawValue)
                    .sink(receiveCompletion: { _ in
                        
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                        
                    }, receiveValue: { (languages: [LessonFilterLanguageDomainModel]) in
                        
                        languagesRef = languages
                        
                        confirmation()
                    })
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
    @MainActor func lessonFilterLanguagesShowNumberOfLessonsPerLanguageTranslatedInMyAppLanguage() async throws {
        
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let getLessonFilterLanguagesUseCase: GetLessonFilterLanguagesUseCase = try getLessonFilterLanguagesUseCase()
        
        let appLanguageEnglish: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
        
        var languagesRef: [LessonFilterLanguageDomainModel] = Array()
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.defaultTestSleep()
                    continuation.resume(returning: ())
                }
                
                getLessonFilterLanguagesUseCase
                    .execute(appLanguage: appLanguageEnglish)
                    .sink(receiveCompletion: { _ in
                        
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                        
                    }, receiveValue: { (languages: [LessonFilterLanguageDomainModel]) in
                        
                        languagesRef = languages
                        
                        confirmation()
                    })
                    .store(in: &cancellables)
            }
        }
        
        await confirmation(expectedCount: 1) { confirmation in
            
            getLessonFilterLanguagesUseCase
                .execute(appLanguage: appLanguageEnglish)
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { (languages: [LessonFilterLanguageDomainModel]) in
                    
                    languagesRef = languages
                    
                    confirmation()
                })
                .store(in: &cancellables)
            
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }

        let afrikaansLanguage: LessonFilterLanguageDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.afrikaans.rawValue})
        let czechLanguage: LessonFilterLanguageDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.czech.rawValue})
        let englishLanguage: LessonFilterLanguageDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.english.rawValue})
        let frenchLanguage: LessonFilterLanguageDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.french.rawValue})
        let spanishLanguage: LessonFilterLanguageDomainModel? = languagesRef.first(where: {$0.id == LanguageCodeDomainModel.spanish.rawValue})
        
        let afrikaansLessonsAvailable: String = try #require(afrikaansLanguage?.lessonsAvailableText)
        let czechLessonsAvailable: String = try #require(czechLanguage?.lessonsAvailableText)
        let englishLessonsAvailable: String = try #require(englishLanguage?.lessonsAvailableText)
        let frenchLessonsAvailable: String = try #require(frenchLanguage?.lessonsAvailableText)
        let spanishLessonsAvailable: String = try #require(spanishLanguage?.lessonsAvailableText)

        #expect(afrikaansLessonsAvailable == "\(englishLessonsAvailableText) 1")
        #expect(czechLessonsAvailable == "\(englishLessonsAvailableText) 1")
        #expect(englishLessonsAvailable == "\(englishLessonsAvailableText) 5")
        #expect(frenchLessonsAvailable == "\(englishLessonsAvailableText) 2")
        #expect(spanishLessonsAvailable == "\(englishLessonsAvailableText) 3")
    }
}

extension GetLessonFilterLanguagesUseCaseTests {
    
    private func getTestsDiContainer() throws -> TestsDiContainer {
                
        return try TestsDiContainer(
            realmFileName: String(describing: GetLessonFilterLanguagesUseCaseTests.self),
            addRealmObjects: getRealmObjects()
        )
    }
    
    private func getRealmObjects() -> [IdentifiableRealmObject] {
        
        let allLanguages: [RealmLanguage] = getAllLanguages()
        
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
        
        return allLanguages + tracts + lessons
    }
    
    private func getLessonFilterLanguagesUseCase() throws -> GetLessonFilterLanguagesUseCase {
        
        let testsDiContainer = try getTestsDiContainer()
        
        let getLessonFilterLanguagesRepository = GetLessonFilterLanguagesUseCase(
            resourcesRepository: testsDiContainer.dataLayer.getResourcesRepository(),
            languagesRepository: testsDiContainer.dataLayer.getLanguagesRepository(),
            getLessonFilterLangauge: getLessonFilterLangauge(testsDiContainer: testsDiContainer)
        )
        
        return getLessonFilterLanguagesRepository
    }
    
    private func getAllLanguages() -> [RealmLanguage] {
        
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
    
    private func getRealmLanguage(languageCode: LanguageCodeDomainModel) -> RealmLanguage {
        
        return MockRealmLanguage.createLanguage(
            language: languageCode,
            name: languageCode.rawValue + " Name",
            id: languageCode.rawValue
        )
    }
    
    private func getLessonFilterLangauge(testsDiContainer: TestsDiContainer) -> GetLessonFilterLanguage {
        return GetLessonFilterLanguage(
            resourcesRepository: testsDiContainer.dataLayer.getResourcesRepository(),
            languagesRepository: testsDiContainer.dataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: getTranslatedLanguageName(),
            localizationServices: getLocalizationServices(),
            stringWithLocaleCount: getStringWithLocaleCount()
        )
    }
    
    private func getLocalizationServices() -> MockLocalizationServices {
        
        let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.rawValue: [LessonFilterStringKeys.lessonsAvailableText.rawValue: englishLessonsAvailableText]
        ]
        
        return MockLocalizationServices.createLanguageNamesLocalizationServices(
            addAdditionalLocalizableStrings: localizableStrings
        )
    }
    
    private func getTranslatedLanguageName() -> GetTranslatedLanguageName {
        
        let getTranslatedLanguageName = GetTranslatedLanguageName(
            localizationLanguageName: MockLocalizationLanguageNameRepository(localizationServices: getLocalizationServices()),
            localeLanguageName: MockLocaleLanguageName.defaultMockLocaleLanguageName(),
            localeRegionName: MockLocaleLanguageRegionName(regionNames: [:]),
            localeScriptName: MockLocaleLanguageScriptName(scriptNames: [:])
        )
        
        return getTranslatedLanguageName
    }
    
    private func getStringWithLocaleCount() -> StringWithLocaleCountInterface {
        
        return MockStringWithLocaleCount()
    }
}
