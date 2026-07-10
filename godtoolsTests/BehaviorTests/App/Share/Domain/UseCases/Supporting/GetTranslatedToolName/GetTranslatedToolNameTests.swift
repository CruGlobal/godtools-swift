//
//  GetTranslatedToolNameTests.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
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
    
    private func getTranslatedToolName() throws -> GetTranslatedToolName {
        
        let testsDiContainer = try TestsDiContainer(
            addRealmObjects: getRealmObjects()
        )
        
        return GetTranslatedToolName(
            resourcesRepository: testsDiContainer.core.dataLayer.getResourcesRepository(),
            translationsRepository: testsDiContainer.core.dataLayer.getTranslationsRepository()
        )
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
                id: toolId,
                attrDefaultLocale: Self.attrDefaultLocale
            )
        ]
        
        let tract0EnglishTranslation: RealmTranslation = MockRealmTranslation.createTranslation(
            translatedName: Self.toolNameInEnglish
        )
        let tract0SpanishTranslation: RealmTranslation = MockRealmTranslation.createTranslation(
            translatedName: Self.toolNameInSpanish
        )
        let tract0VietnameseTranslation: RealmTranslation = MockRealmTranslation.createTranslation(
            translatedName: Self.toolNameInVietnamese
        )
        
        tract0EnglishTranslation.language = englishLanguage
        tract0SpanishTranslation.language = spanishLanguage
        tract0VietnameseTranslation.language = vietnameseLanguage
        
        tracts[0].addLatestTranslation(translation: tract0EnglishTranslation)
        tracts[0].addLatestTranslation(translation: tract0SpanishTranslation)
        tracts[0].addLatestTranslation(translation: tract0VietnameseTranslation)
        
        return allLanguages + tracts
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
}
