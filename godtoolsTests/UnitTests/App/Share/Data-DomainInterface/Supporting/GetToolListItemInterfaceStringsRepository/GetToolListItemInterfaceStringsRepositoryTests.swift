//
//  GetToolListItemInterfaceStringsRepositoryTests.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct GetToolListItemInterfaceStringsRepositoryTests {
    
    private static let keyOpenToolActionTitle: String = "open"
    private static let keyOpenToolDetailsActionTitle: String = "favorites.favoriteLessons.details"
    private static let openToolInEnglish: String = "Open Tool"
    private static let openToolInSpanish: String = "Abrir herramienta"
    private static let toolDetailsInEnglish: String = "Tool Details"
    private static let toolDetailsInSpanish: String = "Detalles de la herramienta"
    
    @Test(
        """
        Given: User viewing a tool card in english.
        When: The app language is switched from english to spanish.
        Then: The tool card interface strings should be translated in spanish.
        """
    )
    func testToolNameIsTranslated() async {
                
        var cancellables: Set<AnyCancellable> = Set()
        
        let getToolListItemInterfaceStrings = GetToolListItemInterfaceStringsRepository(
            localizationServices: Self.getLocalizationServices()
        )
        
        let appLanguagePublisher: CurrentValueSubject<AppLanguageDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
        
        var englishInterfaceStringsRef: ToolListItemInterfaceStringsDomainModel?
        var spanishInterfaceStringsRef: ToolListItemInterfaceStringsDomainModel?
        
        var sinkCount: Int = 0
        
        await confirmation(expectedCount: 2) { confirmation in
            appLanguagePublisher
                .flatMap { appLanguage in
                    
                    return getToolListItemInterfaceStrings.getStringsPublisher(translateInLanguage: appLanguage)
                        .eraseToAnyPublisher()
                }.sink { (interfaceStrings: ToolListItemInterfaceStringsDomainModel) in
                    
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

        
        #expect(englishInterfaceStringsRef?.openToolActionTitle == Self.openToolInEnglish)
        #expect(englishInterfaceStringsRef?.openToolDetailsActionTitle == Self.toolDetailsInEnglish)
        
        #expect(spanishInterfaceStringsRef?.openToolActionTitle == Self.openToolInSpanish)
        #expect(spanishInterfaceStringsRef?.openToolDetailsActionTitle == Self.toolDetailsInSpanish)
    }
}

extension GetToolListItemInterfaceStringsRepositoryTests {
    
    private static func getLocalizationServices() -> MockLocalizationServices {
                
        let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.value: [
                Self.keyOpenToolActionTitle: Self.openToolInEnglish,
                Self.keyOpenToolDetailsActionTitle: Self.toolDetailsInEnglish
            ],
            LanguageCodeDomainModel.spanish.value: [
                Self.keyOpenToolActionTitle: Self.openToolInSpanish,
                Self.keyOpenToolDetailsActionTitle: Self.toolDetailsInSpanish
            ]
        ]
        
        return MockLocalizationServices(localizableStrings: localizableStrings)
    }
}
