//
//  StringWithLocaleCountTests.swift
//  godtools
//
//  Created by Levi Eggert on 8/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation

struct StringWithLocaleCountTests {
    
    struct TestArgument {
        let format: String
        let localeId: String
        let count: Int
        let expectedFormat: String
    }
    
    @Test(
        "",
        arguments: [
            TestArgument(format: "count - %d", localeId: "en", count: 0, expectedFormat: "count - 0")
        ]
    )
    func stringWithCountIsFormattedCorrectly(argument: TestArgument) async {
        
        let value: String = StringWithLocaleCount()
            .getString(
                format: argument.format,
                locale: Locale(identifier: argument.localeId),
                count: argument.count
            )
        
        #expect(value == argument.expectedFormat)
    }
}
