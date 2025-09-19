//
//  GetLessonsListRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct GetLessonsListRepositoryTests {
    
    private static let realmDatabase: RealmDatabase = getRealmDatabase()
    
    private static let spanishLanguageId: String = LanguageCodeDomainModel.spanish.rawValue
    
    @Test(
        """
        Given: User is viewing the lessons list.
        When: My app language is english and lesson language filter is spanish.
        Then: I expect to see lessons that only include the spanish language.
        """
    )
    @MainActor func onlyShowLessonsThatSupportMyLessonLanguageFilter() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let appLanguageEnglish: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
                        
        let spanishLanguageFilter = LessonFilterLanguageDomainModel(
            languageId: Self.spanishLanguageId,
            languageNameTranslatedInLanguage: "",
            languageNameTranslatedInAppLanguage: "",
            lessonsAvailableText: ""
        )
        
        let getLessonsListRepository: GetLessonsListRepository = Self.getLessonsListRepository()
        
        var lessonsRef: [LessonListItemDomainModel] = Array()
        
        var sinkCount: Int = 0
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                continuation.resume(returning: ())
            }
            
            getLessonsListRepository
                .getLessonsListPublisher(
                    appLanguage: appLanguageEnglish,
                    filterLessonsByLanguage: spanishLanguageFilter
                )
                .sink { (lessons: [LessonListItemDomainModel]) in
                                        
                    sinkCount += 1
                    
                    if sinkCount == 1 {
                        
                        lessonsRef = lessons
                        
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    }
                }
                .store(in: &cancellables)
        }
        
        let lessonIds: [String] = lessonsRef
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
    @MainActor func lessonNamesAreTranslatedInAppLanguageWhenNoLanguageFilterSelected() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let appLanguageArabic: AppLanguageDomainModel = LanguageCodeDomainModel.arabic.rawValue
                                
        let getLessonsListRepository: GetLessonsListRepository = Self.getLessonsListRepository()
        
        var lessonsRef: [LessonListItemDomainModel] = Array()
        
        var sinkCount: Int = 0
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                continuation.resume(returning: ())
            }
            
            getLessonsListRepository
                .getLessonsListPublisher(
                    appLanguage: appLanguageArabic,
                    filterLessonsByLanguage: nil
                )
                .sink { (lessons: [LessonListItemDomainModel]) in
                                        
                    sinkCount += 1
                    
                    if sinkCount == 1 {
                        
                        lessonsRef = lessons
                        
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    }
                }
                .store(in: &cancellables)
        }
        
        #expect(lessonsRef.first(where: { $0.id == "0" })?.name == "الدرس صفر")
        #expect(lessonsRef.first(where: { $0.id == "5" })?.name == "الدرس الخامس")
        #expect(lessonsRef.first(where: { $0.id == "6" })?.name == "الدرس السادس")
        #expect(lessonsRef.first(where: { $0.id == "8" })?.name == "الدرس الثامن")
    }
    
    @Test(
        """
        Given: User is viewing the lessons list.
        When: My app language is english and lesson language filter is spanish.
        Then: I expect the lesson names to be translated in my lesson language filter spanish.
        """
    )
    @MainActor func lessonNamesAreTranslatedInLessonLanguageFilter() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let appLanguageEnglish: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
                        
        let spanishLanguageFilter = LessonFilterLanguageDomainModel(
            languageId: LanguageCodeDomainModel.spanish.rawValue,
            languageNameTranslatedInLanguage: "",
            languageNameTranslatedInAppLanguage: "",
            lessonsAvailableText: ""
        )
                                
        let getLessonsListRepository: GetLessonsListRepository = Self.getLessonsListRepository()
        
        var lessonsRef: [LessonListItemDomainModel] = Array()
        
        var sinkCount: Int = 0
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                continuation.resume(returning: ())
            }
            
            getLessonsListRepository
                .getLessonsListPublisher(
                    appLanguage: appLanguageEnglish,
                    filterLessonsByLanguage: spanishLanguageFilter
                )
                .sink { (lessons: [LessonListItemDomainModel]) in
                                        
                    sinkCount += 1
                    
                    if sinkCount == 1 {
                        
                        lessonsRef = lessons
                        
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    }
                }
                .store(in: &cancellables)
        }
        
        #expect(lessonsRef.first(where: { $0.id == "0" })?.name == "Lección cero")
        #expect(lessonsRef.first(where: { $0.id == "2" })?.name == "Leccion dos")
        #expect(lessonsRef.first(where: { $0.id == "4" })?.name == "Lección cuatro")
        #expect(lessonsRef.first(where: { $0.id == "6" })?.name == "Lección seis")
        #expect(lessonsRef.first(where: { $0.id == "8" })?.name == "Lección ocho")
    }
}

extension GetLessonsListRepositoryTests {
 
    private static func getRealmDatabase() -> RealmDatabase {
        
        let afrikaansLanguage: RealmLanguage = Self.getRealmLanguage(languageCode: .afrikaans)
        let arabicLanguage: RealmLanguage =  Self.getRealmLanguage(languageCode: .arabic)
        let chineseLanguage: RealmLanguage =  Self.getRealmLanguage(languageCode: .chinese)
        let czechLanguage: RealmLanguage =  Self.getRealmLanguage(languageCode: .czech)
        let englishLanguage = getRealmLanguage(languageCode: .english)
        let frenchLanguage: RealmLanguage =  Self.getRealmLanguage(languageCode: .french)
        let hebrewLanguage: RealmLanguage =  Self.getRealmLanguage(languageCode: .hebrew)
        let latvianLanguage: RealmLanguage =  Self.getRealmLanguage(languageCode: .latvian)
        let portugueseLanguage: RealmLanguage =  Self.getRealmLanguage(languageCode: .portuguese)
        let russianLanguage: RealmLanguage = getRealmLanguage(languageCode: .russian)
        let spanishLanguage: RealmLanguage = getRealmLanguage(languageCode: .spanish)
        let vietnameseLanguage: RealmLanguage =  Self.getRealmLanguage(languageCode: .vietnamese)
        
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
            MockRealmResource.createLesson(addLanguages: [.arabic, .english, .spanish], fromLanguages: allLanguages, id: "0"),
            MockRealmResource.createLesson(addLanguages: [.afrikaans, .czech, .english], fromLanguages: allLanguages, id: "1"),
            MockRealmResource.createLesson(addLanguages: [.english, .spanish], fromLanguages: allLanguages, id: "2"),
            MockRealmResource.createLesson(addLanguages: [.english], fromLanguages: allLanguages, id: "3"),
            MockRealmResource.createLesson(addLanguages: [.afrikaans, .english, .russian, .spanish], fromLanguages: allLanguages, id: "4"),
            MockRealmResource.createLesson(addLanguages: [.arabic, .english, .french], fromLanguages: allLanguages, id: "5"),
            MockRealmResource.createLesson(addLanguages: [.arabic, .english, .spanish], fromLanguages: allLanguages, id: "6"),
            MockRealmResource.createLesson(addLanguages: [.english, .latvian], fromLanguages: allLanguages, id: "7"),
            MockRealmResource.createLesson(addLanguages: [.arabic, .english, .spanish, .vietnamese], fromLanguages: allLanguages, id: "8"),
            MockRealmResource.createLesson(addLanguages: [.english, .hebrew, .vietnamese], fromLanguages: allLanguages, id: "9")
        ]
                
        let lesson0ArabicTranslation: RealmTranslation = MockRealmTranslation.createTranslation(translatedName: "الدرس صفر")
        let lesson0EnglishTranslation: RealmTranslation = MockRealmTranslation.createTranslation(translatedName: "Lesson Zero")
        let lesson0SpanishTranslation: RealmTranslation = MockRealmTranslation.createTranslation(translatedName: "Lección cero")
        
        let lesson2EnglishTranslation: RealmTranslation = MockRealmTranslation.createTranslation(translatedName: "Lesson Two")
        let lesson2SpanishTranslation: RealmTranslation = MockRealmTranslation.createTranslation(translatedName: "Leccion dos")
        
        let lesson4AfrikaansTranslation: RealmTranslation = MockRealmTranslation.createTranslation(translatedName: "Les vier")
        let lesson4EnglishTranslation: RealmTranslation = MockRealmTranslation.createTranslation(translatedName: "Lesson Four")
        let lesson4SpanishTranslation: RealmTranslation = MockRealmTranslation.createTranslation(translatedName: "Lección cuatro")
        let lesson4RussianTranslation: RealmTranslation = MockRealmTranslation.createTranslation(translatedName: "Урок четвертый")
        
        let lesson5ArabicTranslation: RealmTranslation = MockRealmTranslation.createTranslation(translatedName: "الدرس الخامس")
        let lesson5EnglishTranslation: RealmTranslation = MockRealmTranslation.createTranslation(translatedName: "Lesson Five")
        let lesson5FrenchTranslation: RealmTranslation = MockRealmTranslation.createTranslation(translatedName: "Leçon cinq")
        
        let lesson6ArabicTranslation: RealmTranslation = MockRealmTranslation.createTranslation(translatedName: "الدرس السادس")
        let lesson6EnglishTranslation: RealmTranslation = MockRealmTranslation.createTranslation(translatedName: "Lesson Six")
        let lesson6SpanishTranslation: RealmTranslation = MockRealmTranslation.createTranslation(translatedName: "Lección seis")
        
        let lesson8ArabicTranslation: RealmTranslation = MockRealmTranslation.createTranslation(translatedName: "الدرس الثامن")
        let lesson8EnglishTranslation: RealmTranslation = MockRealmTranslation.createTranslation(translatedName: "Lesson Eight")
        let lesson8SpanishTranslation: RealmTranslation = MockRealmTranslation.createTranslation(translatedName: "Lección ocho")
        let lesson8VietnameseTranslation: RealmTranslation = MockRealmTranslation.createTranslation(translatedName: "Bài học thứ tám")
        
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
        
        let realmDatabase: RealmDatabase = TestsInMemoryRealmDatabase(
            addObjectsToDatabase: allLanguages + lessons
        )
        
        return realmDatabase
    }
    
    private static func getLessonsListRepository() -> GetLessonsListRepository {
                
        let testsDiContainer = TestsDiContainer(realmDatabase: Self.realmDatabase)
        
        return GetLessonsListRepository(
            resourcesRepository: testsDiContainer.dataLayer.getResourcesRepository(),
            languagesRepository: testsDiContainer.dataLayer.getLanguagesRepository(),
            getTranslatedToolName: Self.getTranslatedToolName(testsDiContainer: testsDiContainer),
            getTranslatedToolLanguageAvailability: Self.getTranslatedToolLanguageAvailability(testsDiContainer: testsDiContainer),
            getLessonListItemProgressRepository: testsDiContainer.dataLayer.getLessonListItemProgressRepository()
        )
    }
    
    private static func getRealmLanguage(languageCode: LanguageCodeDomainModel) -> RealmLanguage {
        return MockRealmLanguage.getLanguage(
            language: languageCode,
            name: languageCode.rawValue + " Name",
            id: languageCode.rawValue
        )
    }
    
    private static func getTranslatedToolName(testsDiContainer: TestsDiContainer) -> GetTranslatedToolName {
        return GetTranslatedToolName(
            resourcesRepository: testsDiContainer.dataLayer.getResourcesRepository(),
            translationsRepository: testsDiContainer.dataLayer.getTranslationsRepository()
        )
    }
    
    private static func getTranslatedToolLanguageAvailability(testsDiContainer: TestsDiContainer) -> GetTranslatedToolLanguageAvailability {
        return GetTranslatedToolLanguageAvailability(
            localizationServices: Self.getLocalizationServices(),
            resourcesRepository: testsDiContainer.dataLayer.getResourcesRepository(),
            languagesRepository: testsDiContainer.dataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: Self.getTranslatedLanguageName()
        )
    }
    
    private static func getLocalizationServices() -> MockLocalizationServices {
        return MockLocalizationServices.createLanguageNamesLocalizationServices()
    }
    
    private static func getTranslatedLanguageName() -> GetTranslatedLanguageName {
        
        let getTranslatedLanguageName = GetTranslatedLanguageName(
            localizationLanguageNameRepository: MockLocalizationLanguageNameRepository(localizationServices: Self.getLocalizationServices()),
            localeLanguageName: MockLocaleLanguageName.defaultMockLocaleLanguageName(),
            localeRegionName: MockLocaleLanguageRegionName(regionNames: [:]),
            localeScriptName: MockLocaleLanguageScriptName(scriptNames: [:])
        )
        
        return getTranslatedLanguageName
    }
}
