//
//  Collection+SafeLookupTests.swift
//  SharedAppleExtensions
//
//  Created by Levi Eggert on 3/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import XCTest
import godtools

final class CollectionSafeLookupTests: XCTestCase {
    
    func testSafeLookupValueIsNil() {
                
        let numbers: [Int] = [0, 1, 2, 3]
        let outOfBoundsIndex: Int = numbers.count + 10
        
        XCTAssertNil(numbers[safe: outOfBoundsIndex])
    }
}
