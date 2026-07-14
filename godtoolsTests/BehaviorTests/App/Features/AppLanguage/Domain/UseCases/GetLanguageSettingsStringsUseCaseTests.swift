//
//  GetLanguageSettingsStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import RepositorySync

struct GetLanguageSettingsStringsUseCaseTests {
    
    @Test(
        """
        Given: User is viewing the language settings.
        When: The app language is set to Spanish.
        Then: The interface strings should be translated in Spanish.
        """
    )
    func stringsAreTranslatedInAppLanguage() async throws {
        
        let useCase = try await getUseCase()
        
        let strings = useCase
            .execute(appLanguage: LanguageCodeDomainModel.spanish.rawValue)
                          
        #expect(strings.navTitle == "Ajustes de idioma")
        #expect(strings.appInterfaceLanguageTitle == "Idioma de la interfaz de la aplicación")
        #expect(strings.setAppLanguageMessage == "Establece el idioma en el que deseas que se muestre toda la aplicación.")
        #expect(strings.toolLanguagesAvailableOfflineTitle == "Idiomas de herramientas disponibles sin conexión")
        #expect(strings.downloadToolsForOfflineMessage == "Descarga todas las herramientas en un idioma para que estén disponibles incluso si no tienes WiFi o servicio móvil. Establece el idioma de la herramienta mediante el botón de opciones dentro de una herramienta.")
        #expect(strings.editDownloadedLanguagesButtonTitle == "Editar idiomas descargados")
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
    func chooseAppLanguageButtonTitleIsTranslatedInMyAppLanguage(argument: TestArgumentChooseAppLanguageButtonTitle) async throws {
        
        let useCase = try await getUseCase()
        
        let strings = useCase
            .execute(appLanguage: argument.appLanguage.rawValue)
        
        #expect(strings.chooseAppLanguageButtonTitle == argument.expectedValue)
    }
    
    @Test(
        """
        Given: User is viewing the language settings.
        When: The app language is set.
        Then: I expect to see the number of app languages available translated in my app language.
        """
    )
    func chooseAppLanguageIsTranslatedInMyLanguageEnglish() async throws {
                
        let useCase = try await getUseCase()
        
        let strings = useCase
            .execute(appLanguage: LanguageCodeDomainModel.english.rawValue)

        let expectedValue: String = "\(getAppLanguages().count) Languages available"
        
        #expect(strings.numberOfAppLanguagesAvailable == expectedValue)
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
    
    private func getUseCase() async throws -> GetLanguageSettingsStringsUseCase {
        
        let testsDiContainer = try TestsDiContainer(
            testsAppConfig: TestsAppConfig(
                realmDatabase: FakeRealmDatabase.createRealmDatabase()
            )
        )
        
        let realmDatabase: RealmDatabase = testsDiContainer.core.dataLayer.getSharedRealmDatabase()
        
        let persistence = RealmRepositorySyncPersistence(
            database: realmDatabase,
            mapping: RealmAppLanguageMapping()
        )
        
        let appLanguages: [AppLanguageCodable] = getAppLanguages()
        
        let appLanguagesSync = try await FakeAppLanguagesRepositorySync(
            persistence: testsDiContainer.feature.appLanguage.dataLayer.getAppLanguagesPersistence(),
            appLanguages: appLanguages
        )
        
        let api = AppLanguagesApi()
        
        let appLanguagesRepository = AppLanguagesRepository(
            api: api,
            cache: AppLanguagesCache(persistence: persistence),
            sync: appLanguagesSync
        )
        
        let localizableStrings: [FakeLocalizationServices.LocaleId: [FakeLocalizationServices.StringKey: String]] = [
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
            localizationLanguageName: FakeLocalizationLanguageNameRepository(localizationServices: FakeLocalizationServices(localizableStrings: localizableStrings)),
            localeLanguageName: FakeLocaleLanguageName.getDefault(),
            localeRegionName: FakeLocaleLanguageRegionName(regionNames: [:]),
            localeScriptName: FakeLocaleLanguageScriptName(scriptNames: [:])
        )
        
        let getLanguageSettingsStringsUseCase = GetLanguageSettingsStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: localizableStrings),
            getTranslatedLanguageName: getTranslatedLanguageName,
            appLanguagesRepository: appLanguagesRepository
        )
        
        return getLanguageSettingsStringsUseCase
    }
}
