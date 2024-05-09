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
        
        let numberOfTestAppLanguages: Int = 5
        
        let testsDiContainer = TestsDiContainer()
        
        let testsRealmDatabase: RealmDatabase = testsDiContainer.dataLayer.getSharedRealmDatabase()
        
        let mockAppLanguagesSync: AppLanguagesRepositorySyncInterface = MockAppLanguagesRepositorySync(
            realmDatabase: testsRealmDatabase,
            numberOfAppLanguages: numberOfTestAppLanguages
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
        
        let getLanguageSettingsInterfaceStringsRepository = GetLanguageSettingsInterfaceStringsRepository(
            localizationServices: MockLocalizationServices(localizableStrings: localizableStrings),
            translatedLanguageNameRepository: testsDiContainer.dataLayer.getTranslatedLanguageNameRepository(),
            appLanguagesRepository: testsDiContainer.feature.appLanguage.dataLayer.getAppLanguagesRepository(
                realmDatabase: testsRealmDatabase,
                sync: mockAppLanguagesSync
            )
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
                        
                        _ = appLanguagePublisher
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
                        
                        _ = getLanguageSettingsInterfaceStringsRepository
                            .getStringsPublisher(translateInAppLanguage: "en")
                            .sink { (interfaceStrings: LanguageSettingsInterfaceStringsDomainModel) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                interfaceStringsRef = interfaceStrings
                                
                                done()
                                
                        }
                    }
                    
                    expect(interfaceStringsRef?.chooseAppLanguageButtonTitle).to(equal("English"))
                }
            }
            
            context("When the app language is Spanish.") {
                
                let getLanguageSettingsInterfaceStringsRepository = GetLanguageSettingsInterfaceStringsRepository(
                    localizationServices: MockLocalizationServices(localizableStrings: localizableStrings),
                    translatedLanguageNameRepository: testsDiContainer.dataLayer.getTranslatedLanguageNameRepository(),
                    appLanguagesRepository: testsDiContainer.feature.appLanguage.dataLayer.getAppLanguagesRepository()
                )
                
                it("I expect the choose app language button title to display my app language Spanish translated in Spanish.") {
                                        
                    var interfaceStringsRef: LanguageSettingsInterfaceStringsDomainModel?
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = getLanguageSettingsInterfaceStringsRepository
                            .getStringsPublisher(translateInAppLanguage: "es")
                            .sink { (interfaceStrings: LanguageSettingsInterfaceStringsDomainModel) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                interfaceStringsRef = interfaceStrings
                                
                                done()
                                
                        }
                    }
                    
                    expect(interfaceStringsRef?.chooseAppLanguageButtonTitle).to(equal("español"))
                }
            }
            
            context("When my app language is English.") {
                       
                it("I expect to see the number of app languages available translated in my app language English.") {
                                        
                    var interfaceStringsRef: LanguageSettingsInterfaceStringsDomainModel?
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = getLanguageSettingsInterfaceStringsRepository
                            .getStringsPublisher(translateInAppLanguage: "en")
                            .sink { (interfaceStrings: LanguageSettingsInterfaceStringsDomainModel) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                interfaceStringsRef = interfaceStrings
                                                                
                                done()
                                
                        }
                    }
                                        
                    expect(interfaceStringsRef?.numberOfAppLanguagesAvailable).to(contain("\(numberOfTestAppLanguages)"))
                    expect(interfaceStringsRef?.numberOfAppLanguagesAvailable).to(equal("\(numberOfTestAppLanguages) Languages available"))
                }
            }
        }
    }
}
