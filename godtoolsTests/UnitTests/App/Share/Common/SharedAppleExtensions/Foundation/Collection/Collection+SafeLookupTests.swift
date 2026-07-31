//
//  Collection+SafeLookupTests.swift
//  SharedAppleExtensions
//
//  Created by Levi Eggert on 3/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Testing
import godtools

struct CollectionSafeLookupArgument {

    let index: Int
    let expectedValue: Int
}

struct CollectionSafeLookupTests {

    private static let numbers: [Int] = [0, 1, 2, 3]

    @Test(
        """
        Given: A collection of numbers.
        When: A safe lookup is performed with an index that is within the collection's bounds.
        Then: The value at that index should be returned.
        """,
        arguments: [
            CollectionSafeLookupArgument(index: 0, expectedValue: 0),
            CollectionSafeLookupArgument(index: 1, expectedValue: 1),
            CollectionSafeLookupArgument(index: 3, expectedValue: 3)
        ]
    )
    func safeLookupReturnsValueWhenIndexIsWithinBounds(argument: CollectionSafeLookupArgument) {

        #expect(Self.numbers[safe: argument.index] == argument.expectedValue)
    }

    @Test(
        """
        Given: A collection of numbers.
        When: A safe lookup is performed with an index that is outside the collection's bounds.
        Then: Nil should be returned.
        """,
        arguments: [-10, -1, 4, 14]
    )
    func safeLookupReturnsNilWhenIndexIsOutOfBounds(outOfBoundsIndex: Int) {

        #expect(Self.numbers[safe: outOfBoundsIndex] == nil)
    }
}
