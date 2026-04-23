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
    @MainActor func stringsAreTranslatedWhenAppLanguageChanges() async throws {
        
        let getLanguageSettingsStringsUseCase: GetLanguageSettingsStringsUseCase = try getLanguageSettingsStringsUseCase()
        
        let appLanguagePublisher: CurrentValueSubject<AppLanguageDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
                
        var englishStringsRef: LanguageSettingsStringsDomainModel?
        var spanishStringsRef: LanguageSettingsStringsDomainModel?
                
        var cancellables: Set<AnyCancellable> = Set()
        var triggerCount: Int = 0
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            appLanguagePublisher
                .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<LanguageSettingsStringsDomainModel, Error> in
                    
                    return getLanguageSettingsStringsUseCase
                        .execute(appLanguage: appLanguage)
                        .eraseToAnyPublisher()
                })
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { (strings: LanguageSettingsStringsDomainModel) in
                    
                    triggerCount += 1
                    
                    if triggerCount == 1 {
                        
                        englishStringsRef = strings
                        appLanguagePublisher.send(LanguageCodeDomainModel.spanish.rawValue)
                    }
                    else if triggerCount == 2 {
                        
                        spanishStringsRef = strings
                        
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    }
                })
                .store(in: &cancellables)
        }
        
        #expect(englishStringsRef?.navTitle == "Language settings")
        #expect(englishStringsRef?.appInterfaceLanguageTitle == "App interface language")
        #expect(englishStringsRef?.setAppLanguageMessage == "Set the language you'd like the whole app to be displayed in.")
        #expect(englishStringsRef?.toolLanguagesAvailableOfflineTitle == "Tool languages available offline")
        #expect(englishStringsRef?.downloadToolsForOfflineMessage == "Download all the tools in a language to make them available even if you're out of WiFi or cell service. Set the tool language via the options button within a tool.")
        #expect(englishStringsRef?.editDownloadedLanguagesButtonTitle == "Edit downloaded languages")
                            
        #expect(spanishStringsRef?.navTitle == "Ajustes de idioma")
        #expect(spanishStringsRef?.appInterfaceLanguageTitle == "Idioma de la interfaz de la aplicación")
        #expect(spanishStringsRef?.setAppLanguageMessage == "Establece el idioma en el que deseas que se muestre toda la aplicación.")
        #expect(spanishStringsRef?.toolLanguagesAvailableOfflineTitle == "Idiomas de herramientas disponibles sin conexión")
        #expect(spanishStringsRef?.downloadToolsForOfflineMessage == "Descarga todas las herramientas en un idioma para que estén disponibles incluso si no tienes WiFi o servicio móvil. Establece el idioma de la herramienta mediante el botón de opciones dentro de una herramienta.")
        #expect(spanishStringsRef?.editDownloadedLanguagesButtonTitle == "Editar idiomas descargados")
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
                
        var stringsRef: LanguageSettingsStringsDomainModel?
        
        var cancellables: Set<AnyCancellable> = Set()
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            getLanguageSettingsStringsUseCase
                .execute(
                    appLanguage: argument.appLanguage.rawValue
                )
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { (strings: LanguageSettingsStringsDomainModel) in
                                            
                    stringsRef = strings
                                                                
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }
        
        #expect(stringsRef?.chooseAppLanguageButtonTitle == argument.expectedValue)
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
                
        var stringsRef: LanguageSettingsStringsDomainModel?
        
        var cancellables: Set<AnyCancellable> = Set()
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            getLanguageSettingsStringsUseCase
                .execute(appLanguage: english.rawValue)
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { (strings: LanguageSettingsStringsDomainModel) in
                    
                    stringsRef = strings
                                
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }

        let expectedValue: String = "\(getAppLanguages().count) Languages available"
        
        #expect(stringsRef?.numberOfAppLanguagesAvailable == expectedValue)
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
            dataModelMapping: RealmAppLanguageMapping()
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
            localizationLanguageName: MockLocalizationLanguageNameRepository(localizationServices: MockLocalizationServices(localizableStrings: localizableStrings)),
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
