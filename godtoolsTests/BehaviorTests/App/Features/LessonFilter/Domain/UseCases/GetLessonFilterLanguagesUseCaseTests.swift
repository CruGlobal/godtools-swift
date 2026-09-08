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
import SwiftData
import RepositorySync

struct GetLessonFilterLanguagesUseCaseTests {
    
    private let englishLessonsAvailableText: String = "lessons available"
    
    @available(iOS 17.4, *)
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

        #expect(afrikaansLanguage?.languageNamePair.nameInOwnLanguage == "Afrikaans")
        #expect(afrikaansLanguage?.languageNamePair.nameInAppLanguage == "африкаанс")
        
        #expect(czechLanguage?.languageNamePair.nameInOwnLanguage == "čeština")
        #expect(czechLanguage?.languageNamePair.nameInAppLanguage == "Чешский")
        
        #expect(englishLanguage?.languageNamePair.nameInOwnLanguage == "English")
        #expect(englishLanguage?.languageNamePair.nameInAppLanguage == "Английский")
        
        #expect(frenchLanguage?.languageNamePair.nameInOwnLanguage == "Français")
        #expect(frenchLanguage?.languageNamePair.nameInAppLanguage == "Французский")
        
        #expect(spanishLanguage?.languageNamePair.nameInOwnLanguage == "Español")
        #expect(spanishLanguage?.languageNamePair.nameInAppLanguage == "испанский")
    }
    
    struct TestSortingArgument {
        let appLanguage: LanguageCodeDomainModel
        let expectedValue: [String]
    }
    
    @available(iOS 17.4, *)
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
        
        #expect(languagesRef.map({$0.languageNamePair.nameInAppLanguage}) == argument.expectedValue)
    }
    
    @available(iOS 17.4, *)
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
        
        let afrikaansLessonsAvailable: String = try #require(afrikaansLanguage?.availableText)
        let czechLessonsAvailable: String = try #require(czechLanguage?.availableText)
        let englishLessonsAvailable: String = try #require(englishLanguage?.availableText)
        let frenchLessonsAvailable: String = try #require(frenchLanguage?.availableText)
        let spanishLessonsAvailable: String = try #require(spanishLanguage?.availableText)

        #expect(afrikaansLessonsAvailable == "\(englishLessonsAvailableText) 1")
        #expect(czechLessonsAvailable == "\(englishLessonsAvailableText) 1")
        #expect(englishLessonsAvailable == "\(englishLessonsAvailableText) 5")
        #expect(frenchLessonsAvailable == "\(englishLessonsAvailableText) 2")
        #expect(spanishLessonsAvailable == "\(englishLessonsAvailableText) 3")
    }
}

extension GetLessonFilterLanguagesUseCaseTests {
    
    @available(iOS 17.4, *)
    private func getLessonFilterLanguagesUseCase() throws -> GetLessonFilterLanguagesUseCase {

        let swiftDatabase = SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())

        let context: ModelContext = swiftDatabase.openContext()

        context.insertObjects(objects: getSwiftDatabaseObjects())

        try context.saveIfHasChanges()

        let testsDiContainer = TestsDiContainer(
            testsAppConfig: TestsAppConfig(
                swiftDatabase: swiftDatabase
            )
        )
        
        let getLessonFilterLanguagesRepository = GetLessonFilterLanguagesUseCase(
            resourcesRepository: testsDiContainer.core.dataLayer.getResourcesRepository(),
            languagesRepository: testsDiContainer.core.dataLayer.getLanguagesRepository(),
            mapLanguageToLessonFilterLanguage: mapLanguageToLessonFilterLanguage(testsDiContainer: testsDiContainer)
        )
        
        return getLessonFilterLanguagesRepository
    }
    
    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [any PersistentModel] {

        let allLanguages: [SwiftLanguage] = getAllLanguages()

        let tracts: [SwiftResource] = [
            getSwiftResource(resourceType: .tract, addLanguages: [.english, .arabic, .czech, .spanish], fromLanguages: allLanguages),
            getSwiftResource(resourceType: .tract, addLanguages: [.spanish], fromLanguages: allLanguages),
            getSwiftResource(resourceType: .tract, addLanguages: [.afrikaans, .arabic], fromLanguages: allLanguages),
            getSwiftResource(resourceType: .tract, addLanguages: [.czech, .french, .hebrew], fromLanguages: allLanguages),
            getSwiftResource(resourceType: .tract, addLanguages: [.english, .chinese], fromLanguages: allLanguages),
            getSwiftResource(resourceType: .tract, addLanguages: [.english, .russian], fromLanguages: allLanguages),
            getSwiftResource(resourceType: .tract, addLanguages: [.english, .portuguese], fromLanguages: allLanguages),
            getSwiftResource(resourceType: .tract, addLanguages: [.english, .latvian], fromLanguages: allLanguages)
        ]

        let lessons: [SwiftResource] = [
            getSwiftResource(resourceType: .lesson, addLanguages: [.english], fromLanguages: allLanguages),
            getSwiftResource(resourceType: .lesson, addLanguages: [.english, .spanish], fromLanguages: allLanguages),
            getSwiftResource(resourceType: .lesson, addLanguages: [.afrikaans, .spanish], fromLanguages: allLanguages),
            getSwiftResource(resourceType: .lesson, addLanguages: [.czech, .french], fromLanguages: allLanguages),
            getSwiftResource(resourceType: .lesson, addLanguages: [.english, .french, .spanish], fromLanguages: allLanguages),
            getSwiftResource(resourceType: .lesson, addLanguages: [.english], fromLanguages: allLanguages),
            getSwiftResource(resourceType: .lesson, addLanguages: [.english], fromLanguages: allLanguages)
        ]

        return allLanguages + tracts + lessons
    }

    @available(iOS 17.4, *)
    private func getSwiftResource(resourceType: ResourceType, addLanguages: [LanguageCodeDomainModel], fromLanguages: [SwiftLanguage]) -> SwiftResource {

        let resource: SwiftResource = SwiftResource()
        resource.id = UUID().uuidString
        resource.resourceType = resourceType.rawValue

        resource.addLanguages(
            addLanguages: addLanguages,
            fromLanguages: fromLanguages
        )

        return resource
    }

    @available(iOS 17.4, *)
    private func getAllLanguages() -> [SwiftLanguage] {

        return [
            getSwiftLanguage(languageCode: .afrikaans),
            getSwiftLanguage(languageCode: .arabic),
            getSwiftLanguage(languageCode: .chinese),
            getSwiftLanguage(languageCode: .czech),
            getSwiftLanguage(languageCode: .english),
            getSwiftLanguage(languageCode: .french),
            getSwiftLanguage(languageCode: .hebrew),
            getSwiftLanguage(languageCode: .latvian),
            getSwiftLanguage(languageCode: .portuguese),
            getSwiftLanguage(languageCode: .russian),
            getSwiftLanguage(languageCode: .spanish),
            getSwiftLanguage(languageCode: .vietnamese)
        ]
    }

    @available(iOS 17.4, *)
    private func getSwiftLanguage(languageCode: LanguageCodeDomainModel) -> SwiftLanguage {

        let language = LanguageCodable.random(
            id: languageCode.rawValue,
            code: languageCode.rawValue,
            name: languageCode.rawValue + " Name",
            forceLanguageName: false
        )

        return SwiftLanguage.createNewFrom(model: language.toModel())
    }
    
    private func mapLanguageToLessonFilterLanguage(testsDiContainer: TestsDiContainer) -> MapLanguageToLessonFilterLanguage {
        return MapLanguageToLessonFilterLanguage(
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
