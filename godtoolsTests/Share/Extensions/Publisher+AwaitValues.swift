//
//  Publisher+AwaitValues.swift
//  godtoolsTests
//
//  Created by Claude on 9/24/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

extension Publisher {

    @MainActor func awaitFirstValue(timeout: Duration = .seconds(30)) async throws -> Output {

        let values: [Output] = try await awaitValues(count: 1, timeout: timeout)

        guard let firstValue = values.first else {
            throw PublisherValuesCollectorError.finishedBeforeExpectedValues(expectedValueCount: 1, receivedValueCount: 0)
        }

        return firstValue
    }

    @MainActor func awaitValues(
        count: Int,
        timeout: Duration = .seconds(30),
        whileObserving: (@Sendable () async throws -> Void)? = nil
    ) async throws -> [Output] {

        precondition(count > 0, "Expected value count must be greater than zero.")

        let collector: PublisherValuesCollector<Output> = PublisherValuesCollector(
            expectedValueCount: count,
            whileObserving: whileObserving
        )

        return try await collector.collect(from: self, timeout: timeout)
    }
}
