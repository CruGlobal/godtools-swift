//
//  GetTranslatedPercentageTests.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetTranslatedPercentageTests {
    
    struct TestArgument {
        let percentageValue: Double
        let expectedValue: String
    }
    
    private static let englishLanguage = LanguageCodeDomainModel.english.rawValue
    
    @Test(
        """
        Given: User is viewing a percentage value in english.
        When: The value is a non integer.
        Then: It should round down to the nearest integer.
        """,
        arguments: [
            TestArgument(percentageValue: 0.2449, expectedValue: "24%"),
            TestArgument(percentageValue: 0.001, expectedValue: "0%")
        ]
    )
    func testRoundDownToNearestInteger(argument: TestArgument) {
                
        let getTranslatedPercentage = GetTranslatedPercentage()
        
        let percentageString = getTranslatedPercentage.getTranslatedPercentage(
            percentValue: argument.percentageValue,
            translateInLanguage: Self.englishLanguage
        )
                            
        #expect(percentageString == argument.expectedValue)
    }
    
    @Test(
        """
        Given: User is viewing a percentage value in english.
        When: The value is a non integer.
        Then: It should round up to the nearest integer.
        """,
        arguments: [
            TestArgument(percentageValue: 0.0051, expectedValue: "1%"),
            TestArgument(percentageValue: 0.625000000001, expectedValue: "63%"),
            TestArgument(percentageValue: 0.8599911111111111, expectedValue: "86%")
        ]
    )
    func testRoundUpToNearestInteger(argument: TestArgument) {
                
        let getTranslatedPercentage = GetTranslatedPercentage()
        
        let percentageString = getTranslatedPercentage.getTranslatedPercentage(
            percentValue: argument.percentageValue,
            translateInLanguage: Self.englishLanguage
        )
                            
        #expect(percentageString == argument.expectedValue)
    }
}
