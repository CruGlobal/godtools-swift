//
//  GetLessonFilterLanguagesUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/12/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools
import Combine
import RepositorySync

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
        var didSetLanguages: Bool = false
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            getLessonFilterLanguagesUseCase
                .execute(appLanguage: appLanguageRussian)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in

                }, receiveValue: { (languages: [LessonFilterLanguageDomainModel]) in
                    
                    guard languages.count > 0 && !didSetLanguages else {
                        return
                    }
                    
                    didSetLanguages = true
                    
                    languagesRef = languages
                    
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
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
        var didSetLanguages: Bool = false
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            getLessonFilterLanguagesUseCase
                .execute(appLanguage: argument.appLanguage.rawValue)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { (languages: [LessonFilterLanguageDomainModel]) in
                    
                    guard languages.count > 0 && !didSetLanguages else {
                        return
                    }
                    
                    didSetLanguages = true
                    
                    languagesRef = languages
                    
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
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
        var didSetLanguages: Bool = false

        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            getLessonFilterLanguagesUseCase
                .execute(appLanguage: appLanguageEnglish)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                    
                    
                }, receiveValue: { (languages: [LessonFilterLanguageDomainModel]) in
                    
                    guard languages.count > 0 && !didSetLanguages else {
                        return
                    }
                    
                    didSetLanguages = true
                    
                    languagesRef = languages
                    
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
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
    
    private func getLessonFilterLanguagesUseCase() throws -> GetLessonFilterLanguagesUseCase {
        
        let testsDiContainer = try TestsDiContainer(addRealmObjects: getRealmObjects())
        
        let getLessonFilterLanguagesRepository = GetLessonFilterLanguagesUseCase(
            resourcesRepository: testsDiContainer.core.dataLayer.getResourcesRepository(),
            languagesRepository: testsDiContainer.core.dataLayer.getLanguagesRepository(),
            getLessonFilterLangauge: getLessonFilterLangauge(testsDiContainer: testsDiContainer)
        )
        
        return getLessonFilterLanguagesRepository
    }
    
    private func getRealmObjects() -> [IdentifiableRealmObject] {
        
        let allLanguages: [RealmLanguage] = getAllLanguages()
        
        let tracts = [
            FakeRealmResource.createTract(addLanguages: [.english, .arabic, .czech, .spanish], fromLanguages: allLanguages),
            FakeRealmResource.createTract(addLanguages: [.spanish], fromLanguages: allLanguages),
            FakeRealmResource.createTract(addLanguages: [.afrikaans, .arabic], fromLanguages: allLanguages),
            FakeRealmResource.createTract(addLanguages: [.czech, .french, .hebrew], fromLanguages: allLanguages),
            FakeRealmResource.createTract(addLanguages: [.english, .chinese], fromLanguages: allLanguages),
            FakeRealmResource.createTract(addLanguages: [.english, .russian], fromLanguages: allLanguages),
            FakeRealmResource.createTract(addLanguages: [.english, .portuguese], fromLanguages: allLanguages),
            FakeRealmResource.createTract(addLanguages: [.english, .latvian], fromLanguages: allLanguages)
        ]
        
        let lessons = [
            FakeRealmResource.createLesson(addLanguages: [.english], fromLanguages: allLanguages),
            FakeRealmResource.createLesson(addLanguages: [.english, .spanish], fromLanguages: allLanguages),
            FakeRealmResource.createLesson(addLanguages: [.afrikaans, .spanish], fromLanguages: allLanguages),
            FakeRealmResource.createLesson(addLanguages: [.czech, .french], fromLanguages: allLanguages),
            FakeRealmResource.createLesson(addLanguages: [.english, .french, .spanish], fromLanguages: allLanguages),
            FakeRealmResource.createLesson(addLanguages: [.english], fromLanguages: allLanguages),
            FakeRealmResource.createLesson(addLanguages: [.english], fromLanguages: allLanguages)
        ]
        
        return allLanguages + tracts + lessons
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

        let language = LanguageCodable.random(
            id: languageCode.rawValue,
            code: languageCode.rawValue,
            name: languageCode.rawValue + " Name",
            forceLanguageName: false
        )

        return RealmLanguage.createNewFrom(model: language.toModel())
    }
    
    private func getLessonFilterLangauge(testsDiContainer: TestsDiContainer) -> GetLessonFilterLanguage {
        return GetLessonFilterLanguage(
            resourcesRepository: testsDiContainer.core.dataLayer.getResourcesRepository(),
            languagesRepository: testsDiContainer.core.dataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: getTranslatedLanguageName(),
            localizationServices: getLocalizationServices(),
            stringWithLocaleCount: getStringWithLocaleCount()
        )
    }
    
    private func getLocalizationServices() -> FakeLocalizationServices {
        
        let localizableStrings: [FakeLocalizationServices.LocaleId: [FakeLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.rawValue: [LocalizableStringKeys.lessonsFilterLessonsAvailable.key: englishLessonsAvailableText]
        ]
        
        return FakeLocalizationServices.createLanguageNamesLocalizationServices(
            addAdditionalLocalizableStrings: localizableStrings
        )
    }
    
    private func getTranslatedLanguageName() -> GetTranslatedLanguageName {
        
        let getTranslatedLanguageName = GetTranslatedLanguageName(
            localizationLanguageName: FakeLocalizationLanguageNameRepository(localizationServices: getLocalizationServices()),
            localeLanguageName: FakeLocaleLanguageName.getDefault(),
            localeRegionName: FakeLocaleLanguageRegionName(regionNames: [:]),
            localeScriptName: FakeLocaleLanguageScriptName(scriptNames: [:])
        )
        
        return getTranslatedLanguageName
    }
    
    private func getStringWithLocaleCount() -> StringWithLocaleCountInterface {
        
        return FakeStringWithLocaleCount()
    }
}
