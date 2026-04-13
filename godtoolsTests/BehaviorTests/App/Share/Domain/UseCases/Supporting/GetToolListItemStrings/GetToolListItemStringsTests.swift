//
//  GetToolListItemStringsTests.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct GetToolListItemStringsTests {
    
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
        
        let getToolListItemStrings = GetToolListItemStrings(
            localizationServices: getLocalizationServices()
        )
        
        let appLanguagePublisher: CurrentValueSubject<AppLanguageDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
        
        var englishStringsRef: ToolListItemStringsDomainModel?
        var spanishStringsRef: ToolListItemStringsDomainModel?
        
        var sinkCount: Int = 0
        
        await confirmation(expectedCount: 2) { confirmation in
            appLanguagePublisher
                .flatMap { appLanguage in
                    
                    return getToolListItemStrings.getStringsPublisher(translateInLanguage: appLanguage)
                        .eraseToAnyPublisher()
                }.sink { (strings: ToolListItemStringsDomainModel) in
                    
                    sinkCount += 1
                    confirmation()
                    
                    if sinkCount == 1 {
                        
                        englishStringsRef = strings
                        appLanguagePublisher.send(LanguageCodeDomainModel.spanish.rawValue)

                    }
                    else if sinkCount == 2 {
                        
                        spanishStringsRef = strings
                    }
                }
                .store(in: &cancellables)
        }

        
        #expect(englishStringsRef?.openToolActionTitle == Self.openToolInEnglish)
        #expect(englishStringsRef?.openToolDetailsActionTitle == Self.toolDetailsInEnglish)
        
        #expect(spanishStringsRef?.openToolActionTitle == Self.openToolInSpanish)
        #expect(spanishStringsRef?.openToolDetailsActionTitle == Self.toolDetailsInSpanish)
    }
}

extension GetToolListItemStringsTests {
    
    private func getLocalizationServices() -> MockLocalizationServices {
                
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
