//
//  GetTranslatedToolNameTests.swift
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

struct GetTranslatedToolNameTests {

    struct TestArgument {
        let translateInLanguage: String
        let expectedToolName: String
    }

    private static let attrDefaultLocale: String = LanguageCodeDomainModel.spanish.rawValue
    private static let toolNameInEnglish: String = "Tract Zero"
    private static let toolNameInSpanish: String = "Tratado Zeri"
    private static let toolNameInVietnamese: String = "Đường Zeri"

    private let toolId: String = "0"

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User viewing a tool.
        When: Tool is being viewed in a supported language translation.
        Then: Should see the translated tool name.
        """,
        arguments: [
            TestArgument(translateInLanguage: LanguageCodeDomainModel.english.rawValue, expectedToolName: Self.toolNameInEnglish),
            TestArgument(translateInLanguage: LanguageCodeDomainModel.spanish.rawValue, expectedToolName: Self.toolNameInSpanish),
            TestArgument(translateInLanguage: LanguageCodeDomainModel.vietnamese.rawValue, expectedToolName: Self.toolNameInVietnamese)
        ]
    )
    func testToolNameIsTranslated(argument: TestArgument) throws {

        let getTranslatedToolName = try getTranslatedToolName()

        let translatedToolName: String = getTranslatedToolName.getToolName(
            toolId: toolId,
            translateInLanguage: argument.translateInLanguage
        )

        #expect(translatedToolName == argument.expectedToolName)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User viewing a tool.
        When: Tool is being viewed in an unsupported language translation.
        Then: Should see the default language tool name.
        """,
        arguments: [
            TestArgument(translateInLanguage: LanguageCodeDomainModel.arabic.rawValue, expectedToolName: Self.toolNameInSpanish),
            TestArgument(translateInLanguage: LanguageCodeDomainModel.hebrew.rawValue, expectedToolName: Self.toolNameInSpanish),
            TestArgument(translateInLanguage: LanguageCodeDomainModel.latvian.rawValue, expectedToolName: Self.toolNameInSpanish)
        ]
    )
    func testToolNameIsTranslatedInDefaultLocale(argument: TestArgument) throws {

        let getTranslatedToolName = try getTranslatedToolName()

        let translatedToolName: String = getTranslatedToolName.getToolName(
            toolId: toolId,
            translateInLanguage: argument.translateInLanguage
        )

        #expect(translatedToolName == argument.expectedToolName)
    }
}

extension GetTranslatedToolNameTests {

    @available(iOS 17.4, *)
    private func getTranslatedToolName() throws -> GetTranslatedToolName {

        let swiftDatabase = SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())
        
        let testsAppConfig = TestsAppConfig(
            swiftDatabase: swiftDatabase
        )

        let context: ModelContext = swiftDatabase.openContext()

        context.insertObjects(objects: getSwiftDatabaseObjects())

        try context.saveIfHasChanges()

        let testsDiContainer = TestsDiContainer(
            testsAppConfig: testsAppConfig
        )

        return GetTranslatedToolName(
            resourcesRepository: testsDiContainer.core.dataLayer.getResourcesRepository(),
            translationsRepository: testsDiContainer.core.dataLayer.getTranslationsRepository()
        )
    }

    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [SwiftResource] {

        let englishLanguage: SwiftLanguage = getSwiftLanguage(languageCode: .english)
        let spanishLanguage: SwiftLanguage = getSwiftLanguage(languageCode: .spanish)
        let vietnameseLanguage: SwiftLanguage = getSwiftLanguage(languageCode: .vietnamese)

        let tract: SwiftResource = SwiftResource.createNewFrom(
            model: ResourceCodable.random(
                id: toolId,
                attrDefaultLocale: Self.attrDefaultLocale,
                resourceType: ResourceType.tract.rawValue
            ).toModel()
        )

        for language in [englishLanguage, spanishLanguage, vietnameseLanguage] {
            tract.addLanguage(language: language)
        }

        tract.addLatestTranslation(translation: getSwiftTranslation(translatedName: Self.toolNameInEnglish, language: englishLanguage))
        tract.addLatestTranslation(translation: getSwiftTranslation(translatedName: Self.toolNameInSpanish, language: spanishLanguage))
        tract.addLatestTranslation(translation: getSwiftTranslation(translatedName: Self.toolNameInVietnamese, language: vietnameseLanguage))

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

    @available(iOS 17.4, *)
    private func getSwiftTranslation(translatedName: String, language: SwiftLanguage) -> SwiftTranslation {

        let translation = SwiftTranslation.createNewFrom(
            model: TranslationCodable.random(translatedName: translatedName).toModel()
        )

        translation.language = language

        return translation
    }
}
