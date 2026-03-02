//
//  GetLanguageSettingsStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine
import RepositorySync

@Suite(.serialized)
struct GetLanguageSettingsStringsUseCaseTests {
    
    @Test(
        """
        Given: User is viewing the language settings.
        When: The app is switched from English to Spanish.
        Then: The interface strings should be translated into Spanish.
        """
    )
    @MainActor func interfaceStringsAreTranslatedWhenAppLanguageChanges() async throws {
        
        let getLanguageSettingsStringsUseCase: GetLanguageSettingsStringsUseCase = try getLanguageSettingsStringsUseCase()
        
        let appLanguagePublisher: CurrentValueSubject<AppLanguageDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var englishInterfaceStringsRef: LanguageSettingsStringsDomainModel?
        var spanishInterfaceStringsRef: LanguageSettingsStringsDomainModel?
        
        var sinkCount: Int = 0
        
        await confirmation(expectedCount: 2) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                appLanguagePublisher
                    .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<LanguageSettingsStringsDomainModel, Error> in
                        
                        return getLanguageSettingsStringsUseCase
                            .execute(appLanguage: appLanguage)
                            .eraseToAnyPublisher()
                    })
                    .sink(receiveCompletion: { _ in
                        
                    }, receiveValue: { (interfaceStrings: LanguageSettingsStringsDomainModel) in
                        
                        sinkCount += 1
                        
                        confirmation()
                        
                        if sinkCount == 1 {
                            
                            englishInterfaceStringsRef = interfaceStrings
                            appLanguagePublisher.send(LanguageCodeDomainModel.spanish.rawValue)
                        }
                        else if sinkCount == 2 {
                            
                            spanishInterfaceStringsRef = interfaceStrings
                            
                            // When finished be sure to call:
                            timeoutTask.cancel()
                            continuation.resume(returning: ())
                        }
                    })
                    .store(in: &cancellables)
            }
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
        
        let getLanguageSettingsStringsUseCase: GetLanguageSettingsStringsUseCase = try getLanguageSettingsStringsUseCase()
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var interfaceStringsRef: LanguageSettingsStringsDomainModel?
                        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                getLanguageSettingsStringsUseCase
                    .execute(
                        appLanguage: argument.appLanguage.rawValue
                    )
                    .sink(receiveCompletion: { _ in
                        
                    }, receiveValue: { (interfaceStrings: LanguageSettingsStringsDomainModel) in
                                                
                        interfaceStringsRef = interfaceStrings
                        
                        // Place inside a sink or other async closure:
                        confirmation()
                                                
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    })
                    .store(in: &cancellables)
            }
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
                
        let getLanguageSettingsStringsUseCase: GetLanguageSettingsStringsUseCase = try getLanguageSettingsStringsUseCase()
        
        let english: LanguageCodeDomainModel = .english
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var interfaceStringsRef: LanguageSettingsStringsDomainModel?
                
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                getLanguageSettingsStringsUseCase
                    .execute(appLanguage: english.rawValue)
                    .sink(receiveCompletion: { _ in
                        
                    }, receiveValue: { (interfaceStrings: LanguageSettingsStringsDomainModel) in
                        
                        interfaceStringsRef = interfaceStrings
                        
                        // Place inside a sink or other async closure:
                        confirmation()
                                        
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    })
                    .store(in: &cancellables)
            }
        }

        let expectedValue: String = "\(getAppLanguages().count) Languages available"
        
        #expect(interfaceStringsRef?.numberOfAppLanguagesAvailable == expectedValue)
    }
}

extension GetLanguageSettingsStringsUseCaseTests {
    
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
    
    private func getLanguageSettingsStringsUseCase() throws -> GetLanguageSettingsStringsUseCase {
        
        let testsDiContainer = try TestsDiContainer(
            realmFileName: String(describing: GetLanguageSettingsStringsUseCaseTests.self),
            addRealmObjects: []
        )
        
        let realmDatabase: RealmDatabase = testsDiContainer.dataLayer.getSharedRealmDatabase()
        
        let persistence = RealmRepositorySyncPersistence(
            database: realmDatabase,
            dataModelMapping: RealmAppLanguageDataModelMapping()
        )
        
        let appLanguages: [AppLanguageCodable] = getAppLanguages()
        
        let mockAppLanguagesSync = try MockAppLanguagesRepositorySync(
            realmDatabase: realmDatabase,
            appLanguages: appLanguages
        )
        
        let api = AppLanguagesApi()
        
        let appLanguagesRepository = AppLanguagesRepository(
            externalDataFetch: api,
            persistence: persistence,
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
        
        let getLanguageSettingsStringsUseCase = GetLanguageSettingsStringsUseCase(
            localizationServices: MockLocalizationServices(localizableStrings: localizableStrings),
            getTranslatedLanguageName: getTranslatedLanguageName,
            appLanguagesRepository: appLanguagesRepository
        )
        
        return getLanguageSettingsStringsUseCase
    }
}
