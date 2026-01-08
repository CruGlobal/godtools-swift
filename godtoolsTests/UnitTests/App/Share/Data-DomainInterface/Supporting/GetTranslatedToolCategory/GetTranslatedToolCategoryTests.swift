//
//  GetTranslatedToolCategoryTests.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
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
    @MainActor func testToolNameIsTranslated(argument: TestArgument) throws {
        
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
    
    private func getTestsDiContainer() throws -> TestsDiContainer {
        return try TestsDiContainer(addRealmObjects: getRealmObjects())
    }
    
    private func getRealmObjects() -> [IdentifiableRealmObject] {
        
        let englishLanguage = getRealmLanguage(languageCode: .english)
        let spanishLanguage: RealmLanguage = getRealmLanguage(languageCode: .spanish)
        let vietnameseLanguage: RealmLanguage =  getRealmLanguage(languageCode: .vietnamese)
        
        let allLanguages: [RealmLanguage] = [
            englishLanguage,
            spanishLanguage,
            vietnameseLanguage
        ]
        
        let tracts: [RealmResource] = [
            MockRealmResource.createTract(
                addLanguages: [.english, .spanish, .vietnamese],
                fromLanguages: allLanguages,
                id: Self.toolId,
                attrCategory: Self.attrCategory
            )
        ]

        return allLanguages + tracts
    }
    
    private func getRealmLanguage(languageCode: LanguageCodeDomainModel) -> RealmLanguage {
        return MockRealmLanguage.createLanguage(
            language: languageCode,
            name: languageCode.rawValue + " Name",
            id: languageCode.rawValue
        )
    }
    
    private func getTranslatedToolCategory(testsDiContainer: TestsDiContainer) -> GetTranslatedToolCategory {
        return GetTranslatedToolCategory(
            localizationServices: getLocalizationServices(),
            resourcesRepository: testsDiContainer.dataLayer.getResourcesRepository()
        )
    }
    
    private func getLocalizationServices() -> MockLocalizationServices {
        
        let toolCategoryKey: String = GetTranslatedToolCategory.localizedKeyPrefix + Self.attrCategory
        
        let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
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
        
        return MockLocalizationServices(localizableStrings: localizableStrings)
    }
}
