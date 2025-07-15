//
//  GetTranslatedNumberCountTests.swift
//  godtools
//
//  Created by Levi Eggert on 6/2/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetTranslatedNumberCountTests {
    
    struct TestArgument {
        let integerValue: Int
        let expectedValue: String
    }
    
    private static let englishLanguage = LanguageCodeDomainModel.english.rawValue
    
    @Test(
        "When user is viewing an integer value in english, the value should display in english.",
        arguments: [
            TestArgument(integerValue: 1, expectedValue: "1")
        ]
    )
    func testPercentageIsRoundedDown(argument: TestArgument) {
                
        let getTranslatedNumberCount = GetTranslatedNumberCount()
        
        let translation: String = getTranslatedNumberCount.getTranslatedCount(
            count: argument.integerValue,
            translateInLanguage: LanguageCodeDomainModel.english.rawValue
        )
                            
        #expect(translation == argument.expectedValue)
    }
}
