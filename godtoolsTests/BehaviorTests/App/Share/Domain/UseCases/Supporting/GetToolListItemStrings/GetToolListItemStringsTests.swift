//
//  GetToolListItemStringsTests.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetToolListItemStringsTests {
    
    private let keyOpenToolActionTitle: String = "open"
    private let keyOpenToolDetailsActionTitle: String = "favorites.favoriteLessons.details"
    private let openToolInEnglish: String = "Open Tool"
    private let openToolInSpanish: String = "Abrir herramienta"
    private let toolDetailsInEnglish: String = "Tool Details"
    private let toolDetailsInSpanish: String = "Detalles de la herramienta"
    
    @Test(
        """
        Given: User viewing a tool card..
        When: The app language is set to spanish.
        Then: The tool card interface strings should be translated in spanish.
        """
    )
    func testToolNameIsTranslated() async {
                        
        let getToolListItemStrings = GetToolListItemStrings(
            localizationServices: getLocalizationServices()
        )
        
        let strings = await getToolListItemStrings
            .getStrings(appLanguage: LanguageCodeDomainModel.spanish.rawValue)
        
        #expect(strings.openToolActionTitle == openToolInSpanish)
        #expect(strings.openToolDetailsActionTitle == toolDetailsInSpanish)
    }
}

extension GetToolListItemStringsTests {
    
    private func getLocalizationServices() -> FakeLocalizationServices {
                
        let localizableStrings: [FakeLocalizationServices.LocaleId: [FakeLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.value: [
                keyOpenToolActionTitle: openToolInEnglish,
                keyOpenToolDetailsActionTitle: toolDetailsInEnglish
            ],
            LanguageCodeDomainModel.spanish.value: [
                keyOpenToolActionTitle: openToolInSpanish,
                keyOpenToolDetailsActionTitle: toolDetailsInSpanish
            ]
        ]
        
        return FakeLocalizationServices(localizableStrings: localizableStrings)
    }
}
