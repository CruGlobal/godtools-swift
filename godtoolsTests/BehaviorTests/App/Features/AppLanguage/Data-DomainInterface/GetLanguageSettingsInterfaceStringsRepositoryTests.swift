//
//  GetLanguageSettingsInterfaceStringsRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

@Suite(.serialized)
struct GetLanguageSettingsInterfaceStringsRepositoryTests {
    
    @Test(
        """
        Given: User is viewing the language settings.
        When: The app is switched from English to Spanish.
        Then: The interface strings should be translated into Spanish.
        """
    )
    @MainActor func interfaceStringsAreTranslatedWhenAppLanguageChanges() async throws {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let getLanguageSettingsInterfaceStringsRepository: GetLanguageSettingsInterfaceStringsRepository = try getLanguageSettingsInterfaceStringsRepository()
        
        let appLanguagePublisher: CurrentValueSubject<AppLanguageDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
        
        var englishInterfaceStringsRef: LanguageSettingsInterfaceStringsDomainModel?
        var spanishInterfaceStringsRef: LanguageSettingsInterfaceStringsDomainModel?
        
        var sinkCount: Int = 0
        
        await confirmation(expectedCount: 2) { confirmation in
            
            appLanguagePublisher
                .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<LanguageSettingsInterfaceStringsDomainModel, Never> in
                    
                    return getLanguageSettingsInterfaceStringsRepository
                        .getStringsPublisher(translateInAppLanguage: appLanguage)
                        .eraseToAnyPublisher()
                })
                .sink { (interfaceStrings: LanguageSettingsInterfaceStringsDomainModel) in
                    
                    sinkCount += 1
                    confirmation()
                    
                    if sinkCount == 1 {
                        
                        englishInterfaceStringsRef = interfaceStrings
                        appLanguagePublisher.send(LanguageCodeDomainModel.spanish.rawValue)
                    }
                    else if sinkCount == 2 {
                        
                        spanishInterfaceStringsRef = interfaceStrings
                    }
                }
                .store(in: &cancellables)
        }
        
        #expect(englishInterfaceStringsRef?.navTitle == "Language settings")
        #expect(englishInterfaceStringsRef?.appInterfaceLanguageTitle == "App interface language")
        #expect(englishInterfaceStringsRef?.setAppLanguageMessage == "Set the language you'd like the whole app to be displayed in.")
        #expect(englishInterfaceStringsRef?.toolLanguagesAvailableOfflineTitle == "Tool languages available offline")
        #expect(englishInterfaceStringsRef?.downloadToolsForOfflineMessage == "Download all the tools in a language to make them available even if you're out of WiFi or cell service. Set the tool language via the options button within a tool.")
        #expect(englishInterfaceStringsRef?.editDownloadedLanguagesButtonTitle == "Edit downloaded languages")
                            
        #expect(spanishInterfaceStringsRef?.navTitle == "Ajustes de idioma")
        #expect(spanishInterfaceStringsRef?.appInterfaceLanguageTitle == "Idioma de la interfaz de la aplicación")
        #expect(spanishInterfaceStringsRef?.setAppLanguageMessage == "Establece el idioma en el que deseas que se muestre toda la aplicación.")
        #expect(spanishInterfaceStringsRef?.toolLanguagesAvailableOfflineTitle == "Idiomas de herramientas disponibles sin conexión")
        #expect(spanishInterfaceStringsRef?.downloadToolsForOfflineMessage == "Descarga todas las herramientas en un idioma para que estén disponibles incluso si no tienes WiFi o servicio móvil. Establece el idioma de la herramienta mediante el botón de opciones dentro de una herramienta.")
        #expect(spanishInterfaceStringsRef?.editDownloadedLanguagesButtonTitle == "Editar idiomas descargados")
    }
    
    struct TestArgumentChooseAppLanguageButtonTitle {
        let appLanguage: LanguageCodeDomainModel
        let expectedValue: String
    }
    
    @Test(
        """
        Given: User is viewing the language settings.
        When: The app language is set.
        Then: I expect the choose app language button title to display my chosen app language translated in my chosen app language.
        """,
        arguments: [
            TestArgumentChooseAppLanguageButtonTitle(
                appLanguage: .english,
                expectedValue: "English"
            ),
            TestArgumentChooseAppLanguageButtonTitle(
                appLanguage: .spanish,
                expectedValue: "Español"
            )
        ]
    )
    @MainActor func chooseAppLanguageButtonTitleIsTranslatedInMyAppLanguage(argument: TestArgumentChooseAppLanguageButtonTitle) async throws {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let getLanguageSettingsInterfaceStringsRepository: GetLanguageSettingsInterfaceStringsRepository = try getLanguageSettingsInterfaceStringsRepository()
        
        var interfaceStringsRef: LanguageSettingsInterfaceStringsDomainModel?
        
        var sinkCount: Int = 0
        
        await confirmation(expectedCount: 1) { confirmation in
            
            getLanguageSettingsInterfaceStringsRepository
                .getStringsPublisher(translateInAppLanguage: argument.appLanguage.rawValue)
                .sink { (interfaceStrings: LanguageSettingsInterfaceStringsDomainModel) in
                    
                    sinkCount += 1
                    confirmation()
                    
                    interfaceStringsRef = interfaceStrings
                }
                .store(in: &cancellables)
        }
        
        #expect(interfaceStringsRef?.chooseAppLanguageButtonTitle == argument.expectedValue)
    }
    
    @Test(
        """
        Given: User is viewing the language settings.
        When: The app language is set.
        Then: I expect to see the number of app languages available translated in my app language.
        """
    )
    @MainActor func chooseAppLanguageIsTranslatedInMyLanguageEnglish() async throws {
        
        var cancellables: Set<AnyCancellable> = Set()
                
        let getLanguageSettingsInterfaceStringsRepository: GetLanguageSettingsInterfaceStringsRepository = try getLanguageSettingsInterfaceStringsRepository()
        
        let english: LanguageCodeDomainModel = .english
        
        var interfaceStringsRef: LanguageSettingsInterfaceStringsDomainModel?
        
        var sinkCount: Int = 0
        
        await confirmation(expectedCount: 1) { confirmation in
            
            getLanguageSettingsInterfaceStringsRepository
                .getStringsPublisher(translateInAppLanguage: english.rawValue)
                .sink { (interfaceStrings: LanguageSettingsInterfaceStringsDomainModel) in
                    
                    sinkCount += 1
                    confirmation()
                    
                    interfaceStringsRef = interfaceStrings
                }
                .store(in: &cancellables)
        }
        
        let expectedValue: String = "\(getAppLanguages().count) Languages available"
        
        #expect(interfaceStringsRef?.numberOfAppLanguagesAvailable == expectedValue)
    }
}

extension GetLanguageSettingsInterfaceStringsRepositoryTests {
    
    private func getAppLanguages() -> [AppLanguageCodable] {
        
        let appLanguages: [AppLanguageCodable] = [
            AppLanguageCodable(languageCode: "en", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "es", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hans"),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hant"),
            AppLanguageCodable(languageCode: "lv", languageDirection: .leftToRight, languageScriptCode: nil)
        ]
        
        return appLanguages
    }
    
    private func getLanguageSettingsInterfaceStringsRepository() throws -> GetLanguageSettingsInterfaceStringsRepository {
        
        let testsDiContainer = try TestsDiContainer(
            realmFileName: String(describing: GetLanguageSettingsInterfaceStringsRepositoryTests.self),
            addRealmObjects: []
        )
        
        let testsRealmDatabase: LegacyRealmDatabase = testsDiContainer.dataLayer.getSharedLegacyRealmDatabase()
        
        let appLanguages: [AppLanguageCodable] = getAppLanguages()
        
        let mockAppLanguagesSync: AppLanguagesRepositorySyncInterface = MockAppLanguagesRepositorySync(
            realmDatabase: testsRealmDatabase,
            appLanguages: appLanguages
        )
        
        let appLanguagesRepository: AppLanguagesRepository = testsDiContainer.feature.appLanguage.dataLayer.getAppLanguagesRepository(
            realmDatabase: testsRealmDatabase,
            sync: mockAppLanguagesSync
        )
        
        let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.value: [
                LocalizableStringKeys.languageSettingsNavTitle.key: "Language settings",
                LocalizableStringKeys.languageSettingsAppInterfaceTitle.key: "App interface language",
                LocalizableStringKeys.languageSettingsAppInterfaceMessage.key: "Set the language you'd like the whole app to be displayed in.",
                LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineTitle.key: "Tool languages available offline",
                LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineMessage.key: "Download all the tools in a language to make them available even if you're out of WiFi or cell service. Set the tool language via the options button within a tool.",
                LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineEditDownloadedLanguagesButtonTitle.key: "Edit downloaded languages",
                LocalizableStringDictKeys.languageSettingsAppLanguageNumberAvailable.key: "%d Languages available"
            ],
            LanguageCodeDomainModel.spanish.value: [
                LocalizableStringKeys.languageSettingsNavTitle.key: "Ajustes de idioma",
                LocalizableStringKeys.languageSettingsAppInterfaceTitle.key: "Idioma de la interfaz de la aplicación",
                LocalizableStringKeys.languageSettingsAppInterfaceMessage.key: "Establece el idioma en el que deseas que se muestre toda la aplicación.",
                LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineTitle.key: "Idiomas de herramientas disponibles sin conexión",
                LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineMessage.key: "Descarga todas las herramientas en un idioma para que estén disponibles incluso si no tienes WiFi o servicio móvil. Establece el idioma de la herramienta mediante el botón de opciones dentro de una herramienta.",
                LocalizableStringKeys.languageSettingsToolLanguagesAvailableOfflineEditDownloadedLanguagesButtonTitle.key: "Editar idiomas descargados",
                LocalizableStringDictKeys.languageSettingsAppLanguageNumberAvailable.key: "%d Idiomas disponibles"
            ]
        ]
                
        let getTranslatedLanguageName = GetTranslatedLanguageName(
            localizationLanguageNameRepository: MockLocalizationLanguageNameRepository(localizationServices: MockLocalizationServices(localizableStrings: localizableStrings)),
            localeLanguageName: MockLocaleLanguageName.defaultMockLocaleLanguageName(),
            localeRegionName: MockLocaleLanguageRegionName(regionNames: [:]),
            localeScriptName: MockLocaleLanguageScriptName(scriptNames: [:])
        )
        
        let getLanguageSettingsInterfaceStringsRepository = GetLanguageSettingsInterfaceStringsRepository(
            localizationServices: MockLocalizationServices(localizableStrings: localizableStrings),
            getTranslatedLanguageName: getTranslatedLanguageName,
            appLanguagesRepository: appLanguagesRepository
        )
        
        return getLanguageSettingsInterfaceStringsRepository
    }
}
