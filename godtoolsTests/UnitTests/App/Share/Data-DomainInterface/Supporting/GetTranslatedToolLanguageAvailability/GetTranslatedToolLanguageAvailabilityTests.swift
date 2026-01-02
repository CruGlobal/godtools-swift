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
    
    struct TestArgument {
        let availableInLanguageCode: String
        let translateInLanguage: String
        let expectedIsAvailable: Bool
        let expectedAvailabilityString: String
    }
    
    private static let toolId: String = "0"
    private static let languageNotAvailable: String = "Language Not Available"
    private static let spanishInEnglish: String = "Spanish"
    private static let spanishInSpanish: String = "Español"
    
    @Test(
        """
        Given: User is viewing a tool. 
        When: The tool supports the provided language.
        Then: The tool should be marked as available and the tool language name should be translated and marked as available.
        """,
        arguments: [
            TestArgument(
                availableInLanguageCode: LanguageCodeDomainModel.spanish.rawValue,
                translateInLanguage: LanguageCodeDomainModel.spanish.rawValue,
                expectedIsAvailable: true,
                expectedAvailabilityString: Self.spanishInSpanish + " " + GetTranslatedToolLanguageAvailability.languageAvailableCheck
            ),
            TestArgument(
                availableInLanguageCode: LanguageCodeDomainModel.spanish.rawValue,
                translateInLanguage: LanguageCodeDomainModel.english.rawValue,
                expectedIsAvailable: true,
                expectedAvailabilityString: Self.spanishInEnglish + " " + GetTranslatedToolLanguageAvailability.languageAvailableCheck
            )
        ]
    )
    @MainActor func testTranslateLanguageAvailabilityByToolIdAndLanguageModelIsAvailable(argument: TestArgument) {
        
        let testsDiContainer: TestsDiContainer = Self.getTestsDiContainer()
        let getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability = Self.getTranslatedToolLanguageAvailability(testsDiContainer: testsDiContainer)
        
        let language: LanguageDataModel? = Self.queryLanguage(id: argument.availableInLanguageCode, testsDiContainer: testsDiContainer)
        
        let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel = getTranslatedToolLanguageAvailability.getTranslatedLanguageAvailability(
            toolId: Self.toolId,
            language: language!,
            translateInLanguage: argument.translateInLanguage
        )
        
        print(toolLanguageAvailability)
        
        #expect(toolLanguageAvailability.isAvailable == argument.expectedIsAvailable)
        #expect(toolLanguageAvailability.availabilityString.isEmpty == false)
        #expect(toolLanguageAvailability.availabilityString == argument.expectedAvailabilityString)
    }
    
    @Test(
        """
        Given: User is viewing a tool.
        When: The tool doesn't support the provided language.
        Then: The tool should be marked as not available and availability string should reflect as not available.
        """,
        arguments: [
            TestArgument(
                availableInLanguageCode: LanguageCodeDomainModel.czech.rawValue,
                translateInLanguage: LanguageCodeDomainModel.czech.rawValue,
                expectedIsAvailable: false,
                expectedAvailabilityString: Self.languageNotAvailable
            ),
            TestArgument(
                availableInLanguageCode: LanguageCodeDomainModel.czech.rawValue,
                translateInLanguage: LanguageCodeDomainModel.english.rawValue,
                expectedIsAvailable: false,
                expectedAvailabilityString: Self.languageNotAvailable
            ),
            TestArgument(
                availableInLanguageCode: LanguageCodeDomainModel.french.rawValue,
                translateInLanguage: LanguageCodeDomainModel.english.rawValue,
                expectedIsAvailable: false,
                expectedAvailabilityString: Self.languageNotAvailable
            )
        ]
    )
    @MainActor func testTranslateLanguageAvailabilityByToolIdAndLanguageModelIsNotAvailable(argument: TestArgument) {
        
        let testsDiContainer: TestsDiContainer = Self.getTestsDiContainer()
        let getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability = Self.getTranslatedToolLanguageAvailability(testsDiContainer: testsDiContainer)
        
        let language: LanguageDataModel? = Self.queryLanguage(id: argument.availableInLanguageCode, testsDiContainer: testsDiContainer)
        
        let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel = getTranslatedToolLanguageAvailability.getTranslatedLanguageAvailability(
            toolId: Self.toolId,
            language: language!,
            translateInLanguage: argument.translateInLanguage
        )
        
        print(toolLanguageAvailability)
        
        #expect(toolLanguageAvailability.isAvailable == argument.expectedIsAvailable)
        #expect(toolLanguageAvailability.availabilityString.isEmpty == false)
        #expect(toolLanguageAvailability.availabilityString == argument.expectedAvailabilityString)
    }
    
    @Test(
        """
        Given: User is viewing a tool. 
        When: The tool supports the provided language.
        Then: The tool should be marked as available and the tool language name should be translated and marked as available.
        """,
        arguments: [
            TestArgument(
                availableInLanguageCode: LanguageCodeDomainModel.spanish.rawValue,
                translateInLanguage: LanguageCodeDomainModel.spanish.rawValue,
                expectedIsAvailable: true,
                expectedAvailabilityString: Self.spanishInSpanish + " " + GetTranslatedToolLanguageAvailability.languageAvailableCheck
            ),
            TestArgument(
                availableInLanguageCode: LanguageCodeDomainModel.spanish.rawValue,
                translateInLanguage: LanguageCodeDomainModel.english.rawValue,
                expectedIsAvailable: true,
                expectedAvailabilityString: Self.spanishInEnglish + " " + GetTranslatedToolLanguageAvailability.languageAvailableCheck
            )
        ]
    )
    @MainActor func testTranslateLanguageAvailabilityByToolIdAndAppLanguageIsAvailable(argument: TestArgument) {
        
        let testsDiContainer: TestsDiContainer = Self.getTestsDiContainer()
        let getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability = Self.getTranslatedToolLanguageAvailability(testsDiContainer: testsDiContainer)
                
        let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel = getTranslatedToolLanguageAvailability.getTranslatedLanguageAvailability(
            resource: Self.queryResource(id: Self.toolId, testsDiContainer: testsDiContainer)!,
            language: argument.availableInLanguageCode,
            translateInLanguage: argument.translateInLanguage
        )
        
        print(toolLanguageAvailability)
        
        #expect(toolLanguageAvailability.isAvailable == argument.expectedIsAvailable)
        #expect(toolLanguageAvailability.availabilityString.isEmpty == false)
        #expect(toolLanguageAvailability.availabilityString == argument.expectedAvailabilityString)
    }
    
    @Test(
        """
        Given: User is viewing a tool.
        When: The tool doesn't support the provided language.
        Then: The tool should be marked as not available and availability string should reflect as not available.
        """,
        arguments: [
            TestArgument(
                availableInLanguageCode: LanguageCodeDomainModel.czech.rawValue,
                translateInLanguage: LanguageCodeDomainModel.czech.rawValue,
                expectedIsAvailable: false,
                expectedAvailabilityString: Self.languageNotAvailable
            ),
            TestArgument(
                availableInLanguageCode: LanguageCodeDomainModel.czech.rawValue,
                translateInLanguage: LanguageCodeDomainModel.english.rawValue,
                expectedIsAvailable: false,
                expectedAvailabilityString: Self.languageNotAvailable
            ),
            TestArgument(
                availableInLanguageCode: LanguageCodeDomainModel.french.rawValue,
                translateInLanguage: LanguageCodeDomainModel.english.rawValue,
                expectedIsAvailable: false,
                expectedAvailabilityString: Self.languageNotAvailable
            )
        ]
    )
    @MainActor func testTranslateLanguageAvailabilityByToolIdAndAppLanguageIsNotAvailable(argument: TestArgument) {
        
        let testsDiContainer: TestsDiContainer = Self.getTestsDiContainer()
        let getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability = Self.getTranslatedToolLanguageAvailability(testsDiContainer: testsDiContainer)
                
        let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel = getTranslatedToolLanguageAvailability.getTranslatedLanguageAvailability(
            resource: Self.queryResource(id: Self.toolId, testsDiContainer: testsDiContainer)!,
            language: argument.availableInLanguageCode,
            translateInLanguage: argument.translateInLanguage
        )
        
        print(toolLanguageAvailability)
        
        #expect(toolLanguageAvailability.isAvailable == argument.expectedIsAvailable)
        #expect(toolLanguageAvailability.availabilityString.isEmpty == false)
        #expect(toolLanguageAvailability.availabilityString == argument.expectedAvailabilityString)
    }
}

extension GetTranslatedToolLanguageAvailabilityTests {
    
    @MainActor private static func getTestsDiContainer() -> TestsDiContainer {
        return TestsDiContainer(
            realmDatabase: getConfiguredRealmDatabase()
        )
    }
    
    @MainActor private static func getTranslatedToolLanguageAvailability(testsDiContainer: TestsDiContainer) -> GetTranslatedToolLanguageAvailability {
        return GetTranslatedToolLanguageAvailability(
            localizationServices: Self.getLocalizationServices(),
            resourcesRepository: testsDiContainer.dataLayer.getResourcesRepository(),
            languagesRepository: testsDiContainer.dataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: Self.getTranslatedLanguageName()
        )
    }
    
    private static func getTranslatedLanguageName() -> GetTranslatedLanguageName {
        
        let languageNames: [MockLocaleLanguageName.LanguageCode: [MockLocaleLanguageName.TranslateInLocaleId: MockLocaleLanguageName.LanguageName]] = [
            LanguageCodeDomainModel.czech.rawValue: [
                LanguageCodeDomainModel.czech.rawValue: "čeština",
                LanguageCodeDomainModel.english.rawValue: "Czech",
                LanguageCodeDomainModel.french.rawValue: "tchèque",
                LanguageCodeDomainModel.spanish.rawValue: "Checo"
            ],
            LanguageCodeDomainModel.english.rawValue: [
                LanguageCodeDomainModel.czech.rawValue: "Angličtina",
                LanguageCodeDomainModel.english.rawValue: "English",
                LanguageCodeDomainModel.french.rawValue: "Anglais",
                LanguageCodeDomainModel.spanish.rawValue: "Inglés"
            ],
            LanguageCodeDomainModel.french.rawValue: [
                LanguageCodeDomainModel.czech.rawValue: "francouzština",
                LanguageCodeDomainModel.english.rawValue: "French",
                LanguageCodeDomainModel.french.rawValue: "Français",
                LanguageCodeDomainModel.spanish.rawValue: "Francés"
            ],
            LanguageCodeDomainModel.spanish.rawValue: [
                LanguageCodeDomainModel.czech.rawValue: "španělština",
                LanguageCodeDomainModel.english.rawValue: Self.spanishInEnglish,
                LanguageCodeDomainModel.french.rawValue: "Espagnol",
                LanguageCodeDomainModel.spanish.rawValue: Self.spanishInSpanish
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
                
        let realmDatabase = TestsInMemoryRealmDatabase(
            addObjectsToDatabase: allLanguages + tracts
        )
        
        return realmDatabase
    }
    
    private static func getNewRealmLanguage(languageCode: LanguageCodeDomainModel) -> RealmLanguage {
        return MockRealmLanguage.createLanguage(
            language: languageCode,
            name: languageCode.rawValue + " Name",
            id: languageCode.rawValue
        )
    }
    
    @MainActor private static func queryResource(id: String, testsDiContainer: TestsDiContainer) -> ResourceDataModel? {
        return testsDiContainer.dataLayer.getResourcesRepository().persistence.getObject(id: id)
    }
    
    @MainActor private static func queryLanguage(id: String, testsDiContainer: TestsDiContainer) -> LanguageDataModel? {
        return testsDiContainer.dataLayer.getLanguagesRepository().persistence.getObject(id: id)
    }
    
    private static func getLocalizationServices() -> MockLocalizationServices {
        return MockLocalizationServices(
            localizableStrings: [
                LanguageCodeDomainModel.czech.rawValue: [
                    GetTranslatedToolLanguageAvailability.localizedKeyLanguageNotAvailable: Self.languageNotAvailable
                ],
                LanguageCodeDomainModel.english.rawValue: [
                    GetTranslatedToolLanguageAvailability.localizedKeyLanguageNotAvailable: Self.languageNotAvailable
                ],
                LanguageCodeDomainModel.french.rawValue: [
                    GetTranslatedToolLanguageAvailability.localizedKeyLanguageNotAvailable: Self.languageNotAvailable
                ],
                LanguageCodeDomainModel.spanish.rawValue: [
                    GetTranslatedToolLanguageAvailability.localizedKeyLanguageNotAvailable: Self.languageNotAvailable
                ]
            ]
        )
    }
}
