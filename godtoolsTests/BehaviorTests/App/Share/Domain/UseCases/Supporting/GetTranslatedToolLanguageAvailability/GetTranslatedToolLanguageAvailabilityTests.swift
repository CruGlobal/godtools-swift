//
//  GetTranslatedToolLanguageAvailabilityTests.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import RepositorySync

struct GetTranslatedToolLanguageAvailabilityTests {
    
    struct TestArgument {
        let availableInLanguageCode: String
        let translateInLanguage: String
        let expectedIsAvailable: Bool
        let expectedAvailabilityString: String
    }
    
    private static let languageNotAvailable: String = "Language Not Available"
    private static let spanishInEnglish: String = "Spanish"
    private static let spanishInSpanish: String = "Español"
    
    private let toolId: String = "0"

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
    func testTranslateLanguageAvailabilityByToolIdAndLanguageModelIsAvailable(argument: TestArgument) async throws {
        
        let testsDiContainer = try getTestsDiContainer()
        
        let translatedToolLanguageAvailability = getTranslatedToolLanguageAvailability(testsDiContainer: testsDiContainer)
        
        let language: LanguageDataModel = try #require(queryLanguage(id: argument.availableInLanguageCode, testsDiContainer: testsDiContainer))
        
        let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel = translatedToolLanguageAvailability.getTranslatedLanguageAvailability(
            toolId: toolId,
            language: language,
            translateInLanguage: argument.translateInLanguage
        )
        
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
    func testTranslateLanguageAvailabilityByToolIdAndLanguageModelIsNotAvailable(argument: TestArgument) async throws {
        
        let testsDiContainer = try getTestsDiContainer()
        
        let translatedToolLanguageAvailability = getTranslatedToolLanguageAvailability(testsDiContainer: testsDiContainer)
        
        let language: LanguageDataModel = try #require(queryLanguage(id: argument.availableInLanguageCode, testsDiContainer: testsDiContainer))
        
        let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel = translatedToolLanguageAvailability.getTranslatedLanguageAvailability(
            toolId: toolId,
            language: language,
            translateInLanguage: argument.translateInLanguage
        )
                
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
    func testTranslateLanguageAvailabilityByToolIdAndAppLanguageIsAvailable(argument: TestArgument) async throws {
        
        let testsDiContainer = try getTestsDiContainer()
        
        let translatedToolLanguageAvailability = getTranslatedToolLanguageAvailability(testsDiContainer: testsDiContainer)
                
        let resource: ResourceDataModel = try #require(queryResource(id: toolId, testsDiContainer: testsDiContainer))
        
        let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel = translatedToolLanguageAvailability.getTranslatedLanguageAvailability(
            resource: resource,
            language: argument.availableInLanguageCode,
            translateInLanguage: argument.translateInLanguage
        )
                
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
    func testTranslateLanguageAvailabilityByToolIdAndAppLanguageIsNotAvailable(argument: TestArgument) async throws {
        
        let testsDiContainer = try getTestsDiContainer()
        
        let translatedToolLanguageAvailability = getTranslatedToolLanguageAvailability(testsDiContainer: testsDiContainer)
                
        let resource: ResourceDataModel = try #require(queryResource(id: toolId, testsDiContainer: testsDiContainer))
        
        let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel = translatedToolLanguageAvailability.getTranslatedLanguageAvailability(
            resource: resource,
            language: argument.availableInLanguageCode,
            translateInLanguage: argument.translateInLanguage
        )
                
        #expect(toolLanguageAvailability.isAvailable == argument.expectedIsAvailable)
        #expect(toolLanguageAvailability.availabilityString.isEmpty == false)
        #expect(toolLanguageAvailability.availabilityString == argument.expectedAvailabilityString)
    }
}

extension GetTranslatedToolLanguageAvailabilityTests {
    
    private func queryResource(id: String, testsDiContainer: TestsDiContainer) -> ResourceDataModel? {
        return testsDiContainer.core.dataLayer.getResourcesRepository().getResourceById(id: id)
    }
    
    private func queryLanguage(id: String, testsDiContainer: TestsDiContainer) -> LanguageDataModel? {
        return testsDiContainer.core.dataLayer.getLanguagesRepository().getLanguageById(id: id)
    }
    
    private func getTestsDiContainer() throws -> TestsDiContainer {
            
        return try TestsDiContainer(addRealmObjects: getRealmObjects(toolId: toolId))
    }
    
    private func getTranslatedToolLanguageAvailability(testsDiContainer: TestsDiContainer) -> GetTranslatedToolLanguageAvailability {
                
        return GetTranslatedToolLanguageAvailability(
            localizationServices: getLocalizationServices(),
            resourcesRepository: testsDiContainer.core.dataLayer.getResourcesRepository(),
            languagesRepository: testsDiContainer.core.dataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: getTranslatedLanguageName()
        )
    }
    
    private func getLocalizationServices() -> LocalizationServicesInterface {
        return FakeLocalizationServices(
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
    
    private func getTranslatedLanguageName() -> GetTranslatedLanguageName {
        
        let languageNames: [FakeLocaleLanguageName.LanguageCode: [FakeLocaleLanguageName.TranslateInLocaleId: FakeLocaleLanguageName.LanguageName]] = [
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
        
        let localeLanguageName = FakeLocaleLanguageName(languageNames: languageNames)
        
        let localizationServices = FakeLocalizationServices(
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
        
        return GetTranslatedLanguageName(
            localizationLanguageName: FakeLocalizationLanguageNameRepository(localizationServices: localizationServices),
            localeLanguageName: localeLanguageName,
            localeRegionName: FakeLocaleLanguageRegionName(regionNames: [:]),
            localeScriptName: FakeLocaleLanguageScriptName(scriptNames: [:])
        )
    }
    
    private func getRealmObjects(toolId: String) -> [IdentifiableRealmObject] {
        
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
            FakeRealmResource.createTract(
                addLanguages: [.english, .spanish],
                fromLanguages: allLanguages,
                id: toolId
            )
        ]
                
        return allLanguages + tracts
    }
    
    private func getNewRealmLanguage(languageCode: LanguageCodeDomainModel) -> RealmLanguage {

        let language = LanguageCodable.random(
            id: languageCode.rawValue,
            code: languageCode.rawValue,
            name: languageCode.rawValue + " Name",
            forceLanguageName: false
        )

        return RealmLanguage.createNewFrom(model: language.toModel())
    }
}
