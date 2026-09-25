//
//  PublisherValuesCollectorError.swift
//  godtoolsTests
//
//  Created by Claude on 9/24/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

enum PublisherValuesCollectorError: Error, Equatable, CustomStringConvertible {

    case timedOut(expectedValueCount: Int, receivedValueCount: Int)
    case finishedBeforeExpectedValues(expectedValueCount: Int, receivedValueCount: Int)

    var description: String {

        switch self {

        case .timedOut(let expectedValueCount, let receivedValueCount):
            return "Timed out waiting for \(expectedValueCount) publisher value(s). Received \(receivedValueCount)."

        case .finishedBeforeExpectedValues(let expectedValueCount, let receivedValueCount):
            return "Publisher finished after \(receivedValueCount) of \(expectedValueCount) expected value(s)."
        }
    }
}
