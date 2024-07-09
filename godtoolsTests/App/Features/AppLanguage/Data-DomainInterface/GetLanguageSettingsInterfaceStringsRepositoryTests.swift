//
//  GetLanguageSettingsInterfaceStringsRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class GetLanguageSettingsInterfaceStringsRepositoryTests: QuickSpec {
    
    override class func spec() {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let testsDiContainer = TestsDiContainer()
        
        let testsRealmDatabase: RealmDatabase = testsDiContainer.dataLayer.getSharedRealmDatabase()
        
        let appLanguages: [AppLanguageCodable] = [
            AppLanguageCodable(languageCode: "en", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "es", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hans"),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hant"),
            AppLanguageCodable(languageCode: "lv", languageDirection: .leftToRight, languageScriptCode: nil)
        ]
        
        let numberOfTestAppLanguages: Int = appLanguages.count

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
        
        let languageNames: [MockLocaleLanguageName.LanguageCode: [MockLocaleLanguageName.TranslateInLocaleId: MockLocaleLanguageName.LanguageName]] = [
            LanguageCodeDomainModel.english.rawValue: [
                LanguageCodeDomainModel.english.rawValue: "English",
                LanguageCodeDomainModel.portuguese.rawValue: "Inglês",
                LanguageCodeDomainModel.spanish.rawValue: "Inglés",
                LanguageCodeDomainModel.russian.rawValue: "Английский"
            ],
            LanguageCodeDomainModel.french.rawValue: [
                LanguageCodeDomainModel.czech.rawValue: "francouzština",
                LanguageCodeDomainModel.english.rawValue: "French",
                LanguageCodeDomainModel.portuguese.rawValue: "Francês",
                LanguageCodeDomainModel.spanish.rawValue: "Francés",
                LanguageCodeDomainModel.russian.rawValue: "Французский"
            ],
            LanguageCodeDomainModel.spanish.rawValue: [
                LanguageCodeDomainModel.english.rawValue: "Spanish",
                LanguageCodeDomainModel.portuguese.rawValue: "Espanhol",
                LanguageCodeDomainModel.spanish.rawValue: "Español",
                LanguageCodeDomainModel.russian.rawValue: "испанский"
            ]
        ]
                
        let getTranslatedLanguageName = GetTranslatedLanguageName(
            localizationLanguageNameRepository: MockLocalizationLanguageNameRepository(localizationServices: MockLocalizationServices(localizableStrings: localizableStrings)),
            localeLanguageName: MockLocaleLanguageName(languageNames: languageNames),
            localeRegionName: MockLocaleLanguageRegionName(regionNames: [:]),
            localeScriptName: MockLocaleLanguageScriptName(scriptNames: [:])
        )
        
        let getLanguageSettingsInterfaceStringsRepository = GetLanguageSettingsInterfaceStringsRepository(
            localizationServices: MockLocalizationServices(localizableStrings: localizableStrings),
            getTranslatedLanguageName: getTranslatedLanguageName,
            appLanguagesRepository: appLanguagesRepository
        )
        
        describe("User is viewing the language settings.") {
         
            context("When the app language is switched from English to Spanish.") {
                             
                it("The interface strings should be translated into Spanish.") {
                    
                    let appLanguagePublisher: CurrentValueSubject<AppLanguageDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
                    
                    var englishInterfaceStringsRef: LanguageSettingsInterfaceStringsDomainModel?
                    var spanishInterfaceStringsRef: LanguageSettingsInterfaceStringsDomainModel?
                    
                    var sinkCount: Int = 0
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        appLanguagePublisher
                            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<LanguageSettingsInterfaceStringsDomainModel, Never> in
                                
                                return getLanguageSettingsInterfaceStringsRepository
                                    .getStringsPublisher(translateInAppLanguage: appLanguage)
                                    .eraseToAnyPublisher()
                            })
                            .sink { (interfaceStrings: LanguageSettingsInterfaceStringsDomainModel) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCount += 1
                                
                                if sinkCount == 1 {
                                    
                                    englishInterfaceStringsRef = interfaceStrings
                                }
                                else if sinkCount == 2 {
                                    
                                    spanishInterfaceStringsRef = interfaceStrings
                                    
                                    sinkCompleted = true
                                    
                                    done()
                                }
                                                                
                                if sinkCount == 1 {
                                    appLanguagePublisher.send(LanguageCodeDomainModel.spanish.rawValue)
                                }
                            }
                            .store(in: &cancellables)
                    }

                    expect(englishInterfaceStringsRef?.navTitle).to(equal("Language settings"))
                    expect(englishInterfaceStringsRef?.appInterfaceLanguageTitle).to(equal("App interface language"))
                    expect(englishInterfaceStringsRef?.setAppLanguageMessage).to(equal("Set the language you'd like the whole app to be displayed in."))
                    expect(englishInterfaceStringsRef?.toolLanguagesAvailableOfflineTitle).to(equal("Tool languages available offline"))
                    expect(englishInterfaceStringsRef?.downloadToolsForOfflineMessage).to(equal("Download all the tools in a language to make them available even if you're out of WiFi or cell service. Set the tool language via the options button within a tool."))
                    expect(englishInterfaceStringsRef?.editDownloadedLanguagesButtonTitle).to(equal("Edit downloaded languages"))
                                        
                    expect(spanishInterfaceStringsRef?.navTitle).to(equal("Ajustes de idioma"))
                    expect(spanishInterfaceStringsRef?.appInterfaceLanguageTitle).to(equal("Idioma de la interfaz de la aplicación"))
                    expect(spanishInterfaceStringsRef?.setAppLanguageMessage).to(equal("Establece el idioma en el que deseas que se muestre toda la aplicación."))
                    expect(spanishInterfaceStringsRef?.toolLanguagesAvailableOfflineTitle).to(equal("Idiomas de herramientas disponibles sin conexión"))
                    expect(spanishInterfaceStringsRef?.downloadToolsForOfflineMessage).to(equal("Descarga todas las herramientas en un idioma para que estén disponibles incluso si no tienes WiFi o servicio móvil. Establece el idioma de la herramienta mediante el botón de opciones dentro de una herramienta."))
                    expect(spanishInterfaceStringsRef?.editDownloadedLanguagesButtonTitle).to(equal("Editar idiomas descargados"))
                }
            }
            
            context("When the app language is English.") {
                
                it("I expect the choose app language button title to display my app language English translated in English.") {
                                        
                    var interfaceStringsRef: LanguageSettingsInterfaceStringsDomainModel?
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        getLanguageSettingsInterfaceStringsRepository
                            .getStringsPublisher(translateInAppLanguage: "en")
                            .sink { (interfaceStrings: LanguageSettingsInterfaceStringsDomainModel) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                interfaceStringsRef = interfaceStrings
                                
                                done()
                                
                            }
                            .store(in: &cancellables)
                    }
                    
                    expect(interfaceStringsRef?.chooseAppLanguageButtonTitle).to(equal("English"))
                }
            }
            
            context("When the app language is Spanish.") {
                
                it("I expect the choose app language button title to display my app language Spanish translated in Spanish.") {
                                        
                    var interfaceStringsRef: LanguageSettingsInterfaceStringsDomainModel?
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        getLanguageSettingsInterfaceStringsRepository
                            .getStringsPublisher(translateInAppLanguage: "es")
                            .sink { (interfaceStrings: LanguageSettingsInterfaceStringsDomainModel) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                interfaceStringsRef = interfaceStrings
                                
                                done()
                                
                            }
                            .store(in: &cancellables)
                    }
                    
                    expect(interfaceStringsRef?.chooseAppLanguageButtonTitle).to(equal("Español"))
                }
            }
            
            context("When my app language is English.") {
                       
                it("I expect to see the number of app languages available translated in my app language English.") {
                                        
                    var interfaceStringsRef: LanguageSettingsInterfaceStringsDomainModel?
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        getLanguageSettingsInterfaceStringsRepository
                            .getStringsPublisher(translateInAppLanguage: "en")
                            .sink { (interfaceStrings: LanguageSettingsInterfaceStringsDomainModel) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                interfaceStringsRef = interfaceStrings
                                                                
                                done()
                                
                            }
                            .store(in: &cancellables)
                    }
                                        
                    expect(interfaceStringsRef?.numberOfAppLanguagesAvailable).to(contain("\(numberOfTestAppLanguages)"))
                    expect(interfaceStringsRef?.numberOfAppLanguagesAvailable).to(equal("\(numberOfTestAppLanguages) Languages available"))
                }
            }
        }
    }
}
