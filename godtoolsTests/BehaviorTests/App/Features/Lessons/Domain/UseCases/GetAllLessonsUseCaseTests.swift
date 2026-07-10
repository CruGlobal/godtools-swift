//
//  GetAllLessonsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools
import Combine
import RepositorySync

struct GetAllLessonsUseCaseTests {
    
    @Test(
        """
        Given: User is viewing the lessons list.
        When: My app language is english and lesson language filter is spanish.
        Then: I expect to see lessons that only include the spanish language.
        """
    )
    @MainActor func onlyShowLessonsThatSupportMyLessonLanguageFilter() async throws {
        
        let appLanguageEnglish: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
                        
        let spanishLanguageFilter = LessonFilterLanguageDomainModel(
            languageId: spanishLanguageId,
            languageNameTranslatedInLanguage: "",
            languageNameTranslatedInAppLanguage: "",
            lessonsAvailableText: "",
            lessonsAvailableCount: 0
        )
        
        let getAllLessonsUseCase: GetAllLessonsUseCase = try getAllLessonsUseCase()
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var allLessons: [LessonListItemDomainModel] = Array()
        var didSetAllLessons: Bool = false
                
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            getAllLessonsUseCase
                .execute(
                    appLanguage: appLanguageEnglish,
                    filterLessonsByLanguage: spanishLanguageFilter
                )
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { (lessons: [LessonListItemDomainModel]) in
                    
                    guard lessons.count > 0 && !didSetAllLessons else {
                        return
                    }
                    
                    didSetAllLessons = true
                    
                    allLessons = lessons
                    
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }
        
        let lessonIds: [String] = allLessons
            .map { $0.id }
            .sorted { $0 < $1 }
        
        #expect(lessonIds == ["0", "2", "4", "6", "8"])
    }
    
    @Test(
        """
        Given: User is viewing the lessons list.
        When: My app language is arabic and my lesson language filter hasn't been selected and instead defaults to my app language arabic.
        Then: I expect the lesson names to be translated in arabic.
        """
    )
    @MainActor func lessonNamesAreTranslatedInAppLanguageWhenNoLanguageFilterSelected() async throws {
                
        let appLanguageArabic: AppLanguageDomainModel = LanguageCodeDomainModel.arabic.rawValue
                                
        let getAllLessonsUseCase: GetAllLessonsUseCase = try getAllLessonsUseCase()
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var allLessons: [LessonListItemDomainModel] = Array()
        var didSetAllLessons: Bool = false
            
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            getAllLessonsUseCase
                .execute(
                    appLanguage: appLanguageArabic,
                    filterLessonsByLanguage: nil
                )
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in

                }, receiveValue: { (lessons: [LessonListItemDomainModel]) in
                    
                    guard lessons.count > 0 && !didSetAllLessons else {
                        return
                    }
                    
                    didSetAllLessons = true
                    
                    allLessons = lessons
                    
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }
        
        #expect(allLessons.first(where: { $0.id == "0" })?.name == "الدرس صفر")
        #expect(allLessons.first(where: { $0.id == "5" })?.name == "الدرس الخامس")
        #expect(allLessons.first(where: { $0.id == "6" })?.name == "الدرس السادس")
        #expect(allLessons.first(where: { $0.id == "8" })?.name == "الدرس الثامن")
    }
    
    @Test(
        """
        Given: User is viewing the lessons list.
        When: My app language is english and lesson language filter is spanish.
        Then: I expect the lesson names to be translated in my lesson language filter spanish.
        """
    )
    @MainActor func lessonNamesAreTranslatedInLessonLanguageFilter() async throws {
                
        let appLanguageEnglish: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
                        
        let spanishLanguageFilter = LessonFilterLanguageDomainModel(
            languageId: LanguageCodeDomainModel.spanish.rawValue,
            languageNameTranslatedInLanguage: "",
            languageNameTranslatedInAppLanguage: "",
            lessonsAvailableText: "",
            lessonsAvailableCount: 0
        )
                                
        let getAllLessonsUseCase: GetAllLessonsUseCase = try getAllLessonsUseCase()
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var allLessons: [LessonListItemDomainModel] = Array()
        var didSetAllLessons: Bool = false
                
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            getAllLessonsUseCase
                .execute(
                    appLanguage: appLanguageEnglish,
                    filterLessonsByLanguage: spanishLanguageFilter
                )
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { (lessons: [LessonListItemDomainModel]) in
                    
                    guard lessons.count > 0 && !didSetAllLessons else {
                        return
                    }
                    
                    didSetAllLessons = true
                    
                    allLessons = lessons
                    
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }
        
        #expect(allLessons.first(where: { $0.id == "0" })?.name == "Lección cero")
        #expect(allLessons.first(where: { $0.id == "2" })?.name == "Leccion dos")
        #expect(allLessons.first(where: { $0.id == "4" })?.name == "Lección cuatro")
        #expect(allLessons.first(where: { $0.id == "6" })?.name == "Lección seis")
        #expect(allLessons.first(where: { $0.id == "8" })?.name == "Lección ocho")
    }
}

extension GetAllLessonsUseCaseTests {
     
    private var spanishLanguageId: String {
        return LanguageCodeDomainModel.spanish.rawValue
    }
    
    private func getRealmObjects() -> [IdentifiableRealmObject] {
        
        let afrikaansLanguage: RealmLanguage = getRealmLanguage(languageCode: .afrikaans)
        let arabicLanguage: RealmLanguage =  getRealmLanguage(languageCode: .arabic)
        let chineseLanguage: RealmLanguage =  getRealmLanguage(languageCode: .chinese)
        let czechLanguage: RealmLanguage =  getRealmLanguage(languageCode: .czech)
        let englishLanguage = getRealmLanguage(languageCode: .english)
        let frenchLanguage: RealmLanguage =  getRealmLanguage(languageCode: .french)
        let hebrewLanguage: RealmLanguage =  getRealmLanguage(languageCode: .hebrew)
        let latvianLanguage: RealmLanguage =  getRealmLanguage(languageCode: .latvian)
        let portugueseLanguage: RealmLanguage =  getRealmLanguage(languageCode: .portuguese)
        let russianLanguage: RealmLanguage = getRealmLanguage(languageCode: .russian)
        let spanishLanguage: RealmLanguage = getRealmLanguage(languageCode: .spanish)
        let vietnameseLanguage: RealmLanguage =  getRealmLanguage(languageCode: .vietnamese)
        
        let allLanguages: [RealmLanguage] = [
            afrikaansLanguage,
            arabicLanguage,
            chineseLanguage,
            czechLanguage,
            englishLanguage,
            frenchLanguage,
            hebrewLanguage,
            latvianLanguage,
            portugueseLanguage,
            russianLanguage,
            spanishLanguage,
            vietnameseLanguage
        ]
        
        let lessons: [RealmResource] = [
            FakeRealmResource.createLesson(addLanguages: [.arabic, .english, .spanish], fromLanguages: allLanguages, id: "0"),
            FakeRealmResource.createLesson(addLanguages: [.afrikaans, .czech, .english], fromLanguages: allLanguages, id: "1"),
            FakeRealmResource.createLesson(addLanguages: [.english, .spanish], fromLanguages: allLanguages, id: "2"),
            FakeRealmResource.createLesson(addLanguages: [.english], fromLanguages: allLanguages, id: "3"),
            FakeRealmResource.createLesson(addLanguages: [.afrikaans, .english, .russian, .spanish], fromLanguages: allLanguages, id: "4"),
            FakeRealmResource.createLesson(addLanguages: [.arabic, .english, .french], fromLanguages: allLanguages, id: "5"),
            FakeRealmResource.createLesson(addLanguages: [.arabic, .english, .spanish], fromLanguages: allLanguages, id: "6"),
            FakeRealmResource.createLesson(addLanguages: [.english, .latvian], fromLanguages: allLanguages, id: "7"),
            FakeRealmResource.createLesson(addLanguages: [.arabic, .english, .spanish, .vietnamese], fromLanguages: allLanguages, id: "8"),
            FakeRealmResource.createLesson(addLanguages: [.english, .hebrew, .vietnamese], fromLanguages: allLanguages, id: "9")
        ]
                
        let lesson0ArabicTranslation: RealmTranslation = FakeRealmTranslation.createTranslation(translatedName: "الدرس صفر")
        let lesson0EnglishTranslation: RealmTranslation = FakeRealmTranslation.createTranslation(translatedName: "Lesson Zero")
        let lesson0SpanishTranslation: RealmTranslation = FakeRealmTranslation.createTranslation(translatedName: "Lección cero")
        
        let lesson2EnglishTranslation: RealmTranslation = FakeRealmTranslation.createTranslation(translatedName: "Lesson Two")
        let lesson2SpanishTranslation: RealmTranslation = FakeRealmTranslation.createTranslation(translatedName: "Leccion dos")
        
        let lesson4AfrikaansTranslation: RealmTranslation = FakeRealmTranslation.createTranslation(translatedName: "Les vier")
        let lesson4EnglishTranslation: RealmTranslation = FakeRealmTranslation.createTranslation(translatedName: "Lesson Four")
        let lesson4SpanishTranslation: RealmTranslation = FakeRealmTranslation.createTranslation(translatedName: "Lección cuatro")
        let lesson4RussianTranslation: RealmTranslation = FakeRealmTranslation.createTranslation(translatedName: "Урок четвертый")
        
        let lesson5ArabicTranslation: RealmTranslation = FakeRealmTranslation.createTranslation(translatedName: "الدرس الخامس")
        let lesson5EnglishTranslation: RealmTranslation = FakeRealmTranslation.createTranslation(translatedName: "Lesson Five")
        let lesson5FrenchTranslation: RealmTranslation = FakeRealmTranslation.createTranslation(translatedName: "Leçon cinq")
        
        let lesson6ArabicTranslation: RealmTranslation = FakeRealmTranslation.createTranslation(translatedName: "الدرس السادس")
        let lesson6EnglishTranslation: RealmTranslation = FakeRealmTranslation.createTranslation(translatedName: "Lesson Six")
        let lesson6SpanishTranslation: RealmTranslation = FakeRealmTranslation.createTranslation(translatedName: "Lección seis")
        
        let lesson8ArabicTranslation: RealmTranslation = FakeRealmTranslation.createTranslation(translatedName: "الدرس الثامن")
        let lesson8EnglishTranslation: RealmTranslation = FakeRealmTranslation.createTranslation(translatedName: "Lesson Eight")
        let lesson8SpanishTranslation: RealmTranslation = FakeRealmTranslation.createTranslation(translatedName: "Lección ocho")
        let lesson8VietnameseTranslation: RealmTranslation = FakeRealmTranslation.createTranslation(translatedName: "Bài học thứ tám")
        
        lesson0ArabicTranslation.language = arabicLanguage
        lesson0EnglishTranslation.language = englishLanguage
        lesson0SpanishTranslation.language = spanishLanguage
        
        lesson2EnglishTranslation.language = englishLanguage
        lesson2SpanishTranslation.language = spanishLanguage
        
        lesson4AfrikaansTranslation.language = afrikaansLanguage
        lesson4EnglishTranslation.language = englishLanguage
        lesson4SpanishTranslation.language = spanishLanguage
        lesson4RussianTranslation.language = russianLanguage
        
        lesson5ArabicTranslation.language = arabicLanguage
        lesson5EnglishTranslation.language = englishLanguage
        lesson5FrenchTranslation.language = frenchLanguage
        
        lesson6ArabicTranslation.language = arabicLanguage
        lesson6EnglishTranslation.language = englishLanguage
        lesson6SpanishTranslation.language = spanishLanguage
        
        lesson8ArabicTranslation.language = arabicLanguage
        lesson8EnglishTranslation.language = englishLanguage
        lesson8SpanishTranslation.language = spanishLanguage
        lesson8VietnameseTranslation.language = vietnameseLanguage

        lessons[0].addLatestTranslation(translation: lesson0ArabicTranslation)
        lessons[0].addLatestTranslation(translation: lesson0EnglishTranslation)
        lessons[0].addLatestTranslation(translation: lesson0SpanishTranslation)
        
        lessons[2].addLatestTranslation(translation: lesson2EnglishTranslation)
        lessons[2].addLatestTranslation(translation: lesson2SpanishTranslation)
        
        lessons[4].addLatestTranslation(translation: lesson4AfrikaansTranslation)
        lessons[4].addLatestTranslation(translation: lesson4EnglishTranslation)
        lessons[4].addLatestTranslation(translation: lesson4SpanishTranslation)
        lessons[4].addLatestTranslation(translation: lesson4RussianTranslation)
        
        lessons[5].addLatestTranslation(translation: lesson5ArabicTranslation)
        lessons[5].addLatestTranslation(translation: lesson5EnglishTranslation)
        lessons[5].addLatestTranslation(translation: lesson5FrenchTranslation)
        
        lessons[6].addLatestTranslation(translation: lesson6ArabicTranslation)
        lessons[6].addLatestTranslation(translation: lesson6EnglishTranslation)
        lessons[6].addLatestTranslation(translation: lesson6SpanishTranslation)
        
        lessons[8].addLatestTranslation(translation: lesson8ArabicTranslation)
        lessons[8].addLatestTranslation(translation: lesson8EnglishTranslation)
        lessons[8].addLatestTranslation(translation: lesson8SpanishTranslation)
        lessons[8].addLatestTranslation(translation: lesson8VietnameseTranslation)
        
        return allLanguages + lessons
    }
    
    private func getAllLessonsUseCase() throws -> GetAllLessonsUseCase {
                
        let testsDiContainer = try TestsDiContainer(addRealmObjects: getRealmObjects())
        
        return GetAllLessonsUseCase(
            resourcesRepository: testsDiContainer.core.dataLayer.getResourcesRepository(),
            lessonProgressRepository: testsDiContainer.core.dataLayer.getUserLessonProgressRepository(),
            getLessonsListItems: getLessonsListItems(testsDiContainer: testsDiContainer)
        )
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
    
    private func getLessonsListItems(testsDiContainer: TestsDiContainer) -> GetLessonsListItems {
        
        return GetLessonsListItems(
            languagesRepository: testsDiContainer.core.dataLayer.getLanguagesRepository(),
            getTranslatedToolName: getTranslatedToolName(testsDiContainer: testsDiContainer),
            getTranslatedToolLanguageAvailability: getTranslatedToolLanguageAvailability(testsDiContainer: testsDiContainer),
            getLessonListItemProgress: testsDiContainer.core.domainLayer.supporting.getLessonListItemProgress()
        )
    }
    
    private func getTranslatedToolName(testsDiContainer: TestsDiContainer) -> GetTranslatedToolName {
        return GetTranslatedToolName(
            resourcesRepository: testsDiContainer.core.dataLayer.getResourcesRepository(),
            translationsRepository: testsDiContainer.core.dataLayer.getTranslationsRepository()
        )
    }
    
    private func getTranslatedToolLanguageAvailability(testsDiContainer: TestsDiContainer) -> GetTranslatedToolLanguageAvailability {
        return GetTranslatedToolLanguageAvailability(
            localizationServices: getLocalizationServices(),
            resourcesRepository: testsDiContainer.core.dataLayer.getResourcesRepository(),
            languagesRepository: testsDiContainer.core.dataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: getTranslatedLanguageName()
        )
    }
    
    private func getLocalizationServices() -> FakeLocalizationServices {
        return FakeLocalizationServices.createLanguageNamesLocalizationServices()
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
}
