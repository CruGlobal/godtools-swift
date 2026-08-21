//
//  GetTranslatedToolCategoryTests.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import SwiftData
import RepositorySync

struct GetTranslatedToolCategoryTests {

    struct TestArgument {
        let translateInLanguage: String
        let expectedToolCategory: String
    }

    private static let toolId: String = "0"
    private static let attrCategory: String = "test_category"
    private static let toolCategoryInEnglish: String = "Tool Category"
    private static let toolCategoryInSpanish: String = "Categoría de herramienta"
    private static let toolCategoryInVietnamese: String = "Danh mục công cụ"

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User viewing a tool.
        When: Tool is being viewed in a language.
        Then: Should see the translated category.
        """,
        arguments: [
            TestArgument(translateInLanguage: LanguageCodeDomainModel.english.rawValue, expectedToolCategory: Self.toolCategoryInEnglish),
            TestArgument(translateInLanguage: LanguageCodeDomainModel.spanish.rawValue, expectedToolCategory: Self.toolCategoryInSpanish),
            TestArgument(translateInLanguage: LanguageCodeDomainModel.vietnamese.rawValue, expectedToolCategory: Self.toolCategoryInVietnamese)
        ]
    )
    func testToolNameIsTranslated(argument: TestArgument) async throws {

        let testsDiContainer: TestsDiContainer = try getTestsDiContainer()

        let getTranslatedToolCategory: GetTranslatedToolCategory = getTranslatedToolCategory(
            testsDiContainer: testsDiContainer
        )

        let category: String = getTranslatedToolCategory.getTranslatedCategory(
            toolId: Self.toolId,
            translateInLanguage: argument.translateInLanguage
        )

        #expect(category == argument.expectedToolCategory)
    }
}

extension GetTranslatedToolCategoryTests {

    @available(iOS 17.4, *)
    private func getTestsDiContainer() throws -> TestsDiContainer {

        let swiftDatabase = SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())

        let context: ModelContext = swiftDatabase.openContext()

        context.insertObjects(objects: getSwiftDatabaseObjects())

        try context.saveIfHasChanges()

        return TestsDiContainer(
            testsAppConfig: TestsAppConfig(
                swiftDatabase: swiftDatabase
            )
        )
    }

    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [SwiftResource] {

        let tract: SwiftResource = SwiftResource.createNewFrom(
            model: ResourceCodable.random(
                id: Self.toolId,
                attrCategory: Self.attrCategory,
                resourceType: ResourceType.tract.rawValue
            ).toModel()
        )

        for languageCode in [LanguageCodeDomainModel.english, .spanish, .vietnamese] {
            tract.addLanguage(language: getSwiftLanguage(languageCode: languageCode))
        }

        return [tract]
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

    private func getTranslatedToolCategory(testsDiContainer: TestsDiContainer) -> GetTranslatedToolCategory {
        return GetTranslatedToolCategory(
            localizationServices: getLocalizationServices(),
            resourcesRepository: testsDiContainer.core.dataLayer.getResourcesRepository()
        )
    }

    private func getLocalizationServices() -> FakeLocalizationServices {

        let toolCategoryKey: String = GetTranslatedToolCategory.localizedKeyPrefix + Self.attrCategory

        let localizableStrings: [FakeLocalizationServices.LocaleId: [FakeLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.value: [
                toolCategoryKey: Self.toolCategoryInEnglish
            ],
            LanguageCodeDomainModel.spanish.value: [
                toolCategoryKey: Self.toolCategoryInSpanish
            ],
            LanguageCodeDomainModel.vietnamese.value: [
                toolCategoryKey: Self.toolCategoryInVietnamese
            ]
        ]

        return FakeLocalizationServices(localizableStrings: localizableStrings)
    }
}
