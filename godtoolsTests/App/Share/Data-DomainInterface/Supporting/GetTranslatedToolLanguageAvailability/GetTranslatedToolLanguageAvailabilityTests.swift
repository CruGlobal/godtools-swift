//
//  GetTranslatedToolLanguageAvailabilityTests.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetTranslatedToolLanguageAvailabilityTests {
    
    private static let toolId: String = "0"
    private static let translationToolNameInEnglish: String = "Tract Zero"
    private static let translationToolNameInSpanish: String = "Tratado Zeri"
    private static let languageNotAvailable: String = "Language Not Available"
    
    @Test(
        """
        Given:
        When:
        Then:
        """
    )
    func testTranslateLanguageAvailabilityByToolIdIsAvailable() {
        
        let testsDiContainer: TestsDiContainer = Self.getTestsDiContainer()
        let getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability = Self.getTranslatedToolLanguageAvailability(testsDiContainer: testsDiContainer)
        
        let spanishLanguage: LanguageModel? = Self.queryLanguage(id: LanguageCodeDomainModel.spanish.rawValue, testsDiContainer: testsDiContainer)
        
        let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel = getTranslatedToolLanguageAvailability.getTranslatedLanguageAvailability(
            toolId: Self.toolId,
            language: spanishLanguage!,
            translateInLanguage: LanguageCodeDomainModel.spanish.rawValue
        )
        
        print(toolLanguageAvailability)
        
        #expect(toolLanguageAvailability.isAvailable == true)
        #expect(toolLanguageAvailability.availabilityString.isEmpty == false)
    }
    
    @Test(
        """
        Given:
        When:
        Then:
        """
    )
    func testTranslateLanguageAvailabilityByToolIdIsNotAvailable() {
        
        let testsDiContainer: TestsDiContainer = Self.getTestsDiContainer()
        let getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability = Self.getTranslatedToolLanguageAvailability(testsDiContainer: testsDiContainer)
        
        let czechLanguage: LanguageModel? = Self.queryLanguage(id: LanguageCodeDomainModel.czech.rawValue, testsDiContainer: testsDiContainer)
        
        let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel = getTranslatedToolLanguageAvailability.getTranslatedLanguageAvailability(
            toolId: Self.toolId,
            language: czechLanguage!,
            translateInLanguage: LanguageCodeDomainModel.czech.rawValue
        )
        
        print(toolLanguageAvailability)
        
        #expect(toolLanguageAvailability.isAvailable == false)
        #expect(toolLanguageAvailability.availabilityString.isEmpty == false)
    }
}

extension GetTranslatedToolLanguageAvailabilityTests {
    
    private static func getTestsDiContainer() -> TestsDiContainer {
        return TestsDiContainer(
            realmDatabase: getConfiguredRealmDatabase()
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
    
    private static func getTranslatedLanguageName() -> GetTranslatedLanguageName {
        
        let languageNames: [MockLocaleLanguageName.LanguageCode: [MockLocaleLanguageName.TranslateInLocaleId: MockLocaleLanguageName.LanguageName]] = [
            LanguageCodeDomainModel.english.rawValue: [
                LanguageCodeDomainModel.czech.rawValue: "Angličtina",
                LanguageCodeDomainModel.english.rawValue: "English",
                LanguageCodeDomainModel.french.rawValue: "Anglais",
                LanguageCodeDomainModel.portuguese.rawValue: "Inglês",
                LanguageCodeDomainModel.russian.rawValue: "Английский",
                LanguageCodeDomainModel.spanish.rawValue: "Inglés"
            ],
            LanguageCodeDomainModel.spanish.rawValue: [
                LanguageCodeDomainModel.czech.rawValue: "španělština",
                LanguageCodeDomainModel.english.rawValue: "Spanish",
                LanguageCodeDomainModel.french.rawValue: "Espagnol",
                LanguageCodeDomainModel.portuguese.rawValue: "Espanhol",
                LanguageCodeDomainModel.russian.rawValue: "испанский",
                LanguageCodeDomainModel.spanish.rawValue: "Español"
            ]
        ]
        
        let localeLanguageName = MockLocaleLanguageName(languageNames: languageNames)
        
        return GetTranslatedLanguageName(
            localizationLanguageNameRepository: MockLocalizationLanguageNameRepository(localizationServices: Self.getLocalizationServices()),
            localeLanguageName: localeLanguageName,
            localeRegionName: MockLocaleLanguageRegionName(regionNames: [:]),
            localeScriptName: MockLocaleLanguageScriptName(scriptNames: [:])
        )
    }
    
    private static func getConfiguredRealmDatabase() -> TestsInMemoryRealmDatabase {
        
        let czechLanguage: RealmLanguage = getNewRealmLanguage(languageCode: .czech)
        let englishLanguage: RealmLanguage = getNewRealmLanguage(languageCode: .english)
        let frenchLanguage: RealmLanguage = getNewRealmLanguage(languageCode: .french)
        let portugueseLanguage: RealmLanguage = getNewRealmLanguage(languageCode: .portuguese)
        let russianLanguage: RealmLanguage = getNewRealmLanguage(languageCode: .russian)
        let spanishLanguage: RealmLanguage = getNewRealmLanguage(languageCode: .spanish)
        
        let allLanguages: [RealmLanguage] = [
            czechLanguage,
            englishLanguage,
            frenchLanguage,
            portugueseLanguage,
            russianLanguage,
            spanishLanguage
        ]
        
        let tracts: [RealmResource] = [
            MockRealmResource.createTract(
                addLanguages: [.english, .spanish],
                fromLanguages: allLanguages,
                id: Self.toolId
            )
        ]
        
        let tract0EnglishTranslation: RealmTranslation = MockRealmTranslation.createTranslation(
            translatedName: Self.translationToolNameInEnglish
        )
        let tract0SpanishTranslation: RealmTranslation = MockRealmTranslation.createTranslation(
            translatedName: Self.translationToolNameInSpanish
        )
        
        tract0EnglishTranslation.language = englishLanguage
        tract0SpanishTranslation.language = spanishLanguage
        
        tracts[0].addLatestTranslation(translation: tract0EnglishTranslation)
        tracts[0].addLatestTranslation(translation: tract0SpanishTranslation)
        
        let realmDatabase = TestsInMemoryRealmDatabase(
            addObjectsToDatabase: allLanguages + tracts
        )
        
        return realmDatabase
    }
    
    private static func getNewRealmLanguage(languageCode: LanguageCodeDomainModel) -> RealmLanguage {
        return MockRealmLanguage.getLanguage(
            language: languageCode,
            name: languageCode.rawValue + " Name",
            id: languageCode.rawValue
        )
    }
    
    private static func queryLanguage(id: String, testsDiContainer: TestsDiContainer) -> LanguageModel? {
        return testsDiContainer.dataLayer.getLanguagesRepository().getLanguage(id: id)
    }
    
    private static func getLocalizationServices() -> MockLocalizationServices {
        return MockLocalizationServices(
            localizableStrings: [
                LanguageCodeDomainModel.czech.rawValue: [
                    GetTranslatedToolLanguageAvailability.localizedKeyLanguageNotAvailable: Self.languageNotAvailable
                ],
                LanguageCodeDomainModel.french.rawValue: [
                    GetTranslatedToolLanguageAvailability.localizedKeyLanguageNotAvailable: Self.languageNotAvailable
                ],
                LanguageCodeDomainModel.portuguese.rawValue: [
                    GetTranslatedToolLanguageAvailability.localizedKeyLanguageNotAvailable: Self.languageNotAvailable
                ],
                LanguageCodeDomainModel.russian.rawValue: [
                    GetTranslatedToolLanguageAvailability.localizedKeyLanguageNotAvailable: Self.languageNotAvailable
                ]
            ]
        )
    }
}
