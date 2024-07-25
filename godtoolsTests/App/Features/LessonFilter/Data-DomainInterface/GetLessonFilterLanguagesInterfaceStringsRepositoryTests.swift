//
//  GetLessonFilterLanguagesInterfaceStringsRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/12/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class GetLessonFilterLanguagesInterfaceStringsRepositoryTests: QuickSpec {
    
    override class func spec() {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        describe("User is viewing the lesson filter languages.") {
         
            context("When the app language is switched from English to Spanish.") {
                
                it("The interface strings should be translated into Spanish.") {
                    
                    let navTitleKey: String = LessonFilterStringKeys.navTitle.rawValue
                    
                    let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
                        LanguageCodeDomainModel.english.value: [
                            navTitleKey: "Lesson language"
                        ],
                        LanguageCodeDomainModel.spanish.value: [
                            navTitleKey: "Idioma de la lección"
                        ]
                    ]
                    
                    let getLessonFilterLanguagesInterfaceStringsRepository = GetLessonFilterLanguagesInterfaceStringsRepository(
                        localizationServices: MockLocalizationServices(localizableStrings: localizableStrings)
                    )
                    
                    let appLanguagePublisher: CurrentValueSubject<AppLanguageDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
                    
                    var englishInterfaceStringsRef: LessonFilterLanguagesInterfaceStringsDomainModel?
                    var spanishInterfaceStringsRef: LessonFilterLanguagesInterfaceStringsDomainModel?
                    
                    var sinkCount: Int = 0
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        appLanguagePublisher
                            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<LessonFilterLanguagesInterfaceStringsDomainModel, Never> in
                                
                                return getLessonFilterLanguagesInterfaceStringsRepository
                                    .getStringsPublisher(translateInAppLanguage: appLanguage)
                                    .eraseToAnyPublisher()
                            })
                            .sink { (interfaceStrings: LessonFilterLanguagesInterfaceStringsDomainModel) in
                                
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

                    expect(englishInterfaceStringsRef?.navTitle).to(equal("Lesson language"))
                    expect(spanishInterfaceStringsRef?.navTitle).to(equal("Idioma de la lección"))
                }
            }
        }
    }
}
