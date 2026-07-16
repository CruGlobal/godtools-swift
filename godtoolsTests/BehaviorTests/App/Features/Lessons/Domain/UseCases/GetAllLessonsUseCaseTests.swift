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
import SwiftData
import RepositorySync

struct GetAllLessonsUseCaseTests {

    @available(iOS 17.4, *)
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

    @available(iOS 17.4, *)
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

    @available(iOS 17.4, *)
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

    @available(iOS 17.4, *)
    private func getAllLessonsUseCase() throws -> GetAllLessonsUseCase {

        let swiftDatabase = SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())

        let context: ModelContext = swiftDatabase.openContext()

        context.insertObjects(objects: getSwiftDatabaseObjects())

        try context.saveIfHasChanges()

        let testsDiContainer = TestsDiContainer(
            testsAppConfig: TestsAppConfig(
                swiftDatabase: swiftDatabase
            )
        )

        return GetAllLessonsUseCase(
            resourcesRepository: testsDiContainer.core.dataLayer.getResourcesRepository(),
            lessonProgressRepository: testsDiContainer.core.dataLayer.getUserLessonProgressRepository(),
            getLessonsListItems: getLessonsListItems(testsDiContainer: testsDiContainer)
        )
    }

    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [any PersistentModel] {

        let afrikaansLanguage: SwiftLanguage = getSwiftLanguage(languageCode: .afrikaans)
        let arabicLanguage: SwiftLanguage = getSwiftLanguage(languageCode: .arabic)
        let chineseLanguage: SwiftLanguage = getSwiftLanguage(languageCode: .chinese)
        let czechLanguage: SwiftLanguage = getSwiftLanguage(languageCode: .czech)
        let englishLanguage: SwiftLanguage = getSwiftLanguage(languageCode: .english)
        let frenchLanguage: SwiftLanguage = getSwiftLanguage(languageCode: .french)
        let hebrewLanguage: SwiftLanguage = getSwiftLanguage(languageCode: .hebrew)
        let latvianLanguage: SwiftLanguage = getSwiftLanguage(languageCode: .latvian)
        let portugueseLanguage: SwiftLanguage = getSwiftLanguage(languageCode: .portuguese)
        let russianLanguage: SwiftLanguage = getSwiftLanguage(languageCode: .russian)
        let spanishLanguage: SwiftLanguage = getSwiftLanguage(languageCode: .spanish)
        let vietnameseLanguage: SwiftLanguage = getSwiftLanguage(languageCode: .vietnamese)

        let allLanguages: [SwiftLanguage] = [
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

        let lessons: [SwiftResource] = [
            getSwiftLesson(id: "0", addLanguages: [.arabic, .english, .spanish], fromLanguages: allLanguages),
            getSwiftLesson(id: "1", addLanguages: [.afrikaans, .czech, .english], fromLanguages: allLanguages),
            getSwiftLesson(id: "2", addLanguages: [.english, .spanish], fromLanguages: allLanguages),
            getSwiftLesson(id: "3", addLanguages: [.english], fromLanguages: allLanguages),
            getSwiftLesson(id: "4", addLanguages: [.afrikaans, .english, .russian, .spanish], fromLanguages: allLanguages),
            getSwiftLesson(id: "5", addLanguages: [.arabic, .english, .french], fromLanguages: allLanguages),
            getSwiftLesson(id: "6", addLanguages: [.arabic, .english, .spanish], fromLanguages: allLanguages),
            getSwiftLesson(id: "7", addLanguages: [.english, .latvian], fromLanguages: allLanguages),
            getSwiftLesson(id: "8", addLanguages: [.arabic, .english, .spanish, .vietnamese], fromLanguages: allLanguages),
            getSwiftLesson(id: "9", addLanguages: [.english, .hebrew, .vietnamese], fromLanguages: allLanguages)
        ]

        lessons[0].addLatestTranslation(translation: getSwiftTranslation(translatedName: "الدرس صفر", language: arabicLanguage))
        lessons[0].addLatestTranslation(translation: getSwiftTranslation(translatedName: "Lesson Zero", language: englishLanguage))
        lessons[0].addLatestTranslation(translation: getSwiftTranslation(translatedName: "Lección cero", language: spanishLanguage))

        lessons[2].addLatestTranslation(translation: getSwiftTranslation(translatedName: "Lesson Two", language: englishLanguage))
        lessons[2].addLatestTranslation(translation: getSwiftTranslation(translatedName: "Leccion dos", language: spanishLanguage))

        lessons[4].addLatestTranslation(translation: getSwiftTranslation(translatedName: "Les vier", language: afrikaansLanguage))
        lessons[4].addLatestTranslation(translation: getSwiftTranslation(translatedName: "Lesson Four", language: englishLanguage))
        lessons[4].addLatestTranslation(translation: getSwiftTranslation(translatedName: "Lección cuatro", language: spanishLanguage))
        lessons[4].addLatestTranslation(translation: getSwiftTranslation(translatedName: "Урок четвертый", language: russianLanguage))

        lessons[5].addLatestTranslation(translation: getSwiftTranslation(translatedName: "الدرس الخامس", language: arabicLanguage))
        lessons[5].addLatestTranslation(translation: getSwiftTranslation(translatedName: "Lesson Five", language: englishLanguage))
        lessons[5].addLatestTranslation(translation: getSwiftTranslation(translatedName: "Leçon cinq", language: frenchLanguage))

        lessons[6].addLatestTranslation(translation: getSwiftTranslation(translatedName: "الدرس السادس", language: arabicLanguage))
        lessons[6].addLatestTranslation(translation: getSwiftTranslation(translatedName: "Lesson Six", language: englishLanguage))
        lessons[6].addLatestTranslation(translation: getSwiftTranslation(translatedName: "Lección seis", language: spanishLanguage))

        lessons[8].addLatestTranslation(translation: getSwiftTranslation(translatedName: "الدرس الثامن", language: arabicLanguage))
        lessons[8].addLatestTranslation(translation: getSwiftTranslation(translatedName: "Lesson Eight", language: englishLanguage))
        lessons[8].addLatestTranslation(translation: getSwiftTranslation(translatedName: "Lección ocho", language: spanishLanguage))
        lessons[8].addLatestTranslation(translation: getSwiftTranslation(translatedName: "Bài học thứ tám", language: vietnameseLanguage))

        return allLanguages + lessons
    }

    @available(iOS 17.4, *)
    private func getSwiftLesson(id: String, addLanguages: [LanguageCodeDomainModel], fromLanguages: [SwiftLanguage]) -> SwiftResource {

        let lesson: SwiftResource = SwiftResource()
        lesson.id = id
        lesson.resourceType = ResourceType.lesson.rawValue

        lesson.addLanguages(
            addLanguages: addLanguages,
            fromLanguages: fromLanguages
        )

        return lesson
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

    @available(iOS 17.4, *)
    private func getSwiftTranslation(translatedName: String, language: SwiftLanguage) -> SwiftTranslation {

        let translation = SwiftTranslation.createNewFrom(
            model: TranslationCodable.random(translatedName: translatedName).toModel()
        )

        translation.language = language

        return translation
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
