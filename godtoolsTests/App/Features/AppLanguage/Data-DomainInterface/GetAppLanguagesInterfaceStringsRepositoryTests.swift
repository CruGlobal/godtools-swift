//
//  GetAppLanguagesInterfaceStringsRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/5/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class GetAppLanguagesInterfaceStringsRepositoryTests: QuickSpec {
    
    override class func spec() {
        
        describe("When a user is viewing the app languages.") {
         
            context("When the app language is switched from English to Spanish.") {
                
                let chooseLanguageButtonTitleKey: String = "onboardingTutorial.chooseLanguageButton.title"
                let beginButtonTitleKey: String = "onboardingTutorial.beginButton.title"
                
                let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
                    LanguageCodeDomainModel.english.value: [
                        chooseLanguageButtonTitleKey: "Choose Language",
                        beginButtonTitleKey: "Begin"
                    ],
                    LanguageCodeDomainModel.spanish.value: [
                        chooseLanguageButtonTitleKey: "Elige lengua",
                        beginButtonTitleKey: "Comenzar"
                    ]
                ]
                
                let getOnboardingTutorialInterfaceStringsRepository =  GetOnboardingTutorialInterfaceStringsRepository(
                    localizationServices: MockLocalizationServices(
                        localizableStrings: localizableStrings
                    )
                )
                
                it("The interface strings should be translated into Spanish.") {
                    
                    let appLanguagePublisher: CurrentValueSubject<AppLanguageDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
                    
                    var englishInterfaceStringsRef: OnboardingTutorialInterfaceStringsDomainModel?
                    var spanishInterfaceStringsRef: OnboardingTutorialInterfaceStringsDomainModel?
                    
                    var sinkCount: Int = 0
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = appLanguagePublisher
                            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<OnboardingTutorialInterfaceStringsDomainModel, Never> in
                                
                                return getOnboardingTutorialInterfaceStringsRepository
                                    .getStringsPublisher(appLanguage: appLanguage)
                                    .eraseToAnyPublisher()
                            })
                            .sink { (interfaceStrings: OnboardingTutorialInterfaceStringsDomainModel) in
                                
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

                    expect(englishInterfaceStringsRef?.chooseAppLanguageButtonTitle).to(equal("Choose Language"))
                    expect(englishInterfaceStringsRef?.beginTutorialButtonTitle).to(equal("Begin"))
                    
                    expect(spanishInterfaceStringsRef?.chooseAppLanguageButtonTitle).to(equal("Elige lengua"))
                    expect(spanishInterfaceStringsRef?.beginTutorialButtonTitle).to(equal("Comenzar"))
                }
            }
        }
    }
}

