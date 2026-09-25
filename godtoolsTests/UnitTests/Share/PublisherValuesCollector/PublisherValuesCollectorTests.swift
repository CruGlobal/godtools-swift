//
//  PublisherValuesCollectorTests.swift
//  godtoolsTests
//
//  Created by Claude on 9/24/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools
import Combine

struct PublisherValuesCollectorTests {

    enum TestPublisherError: Error {
        case failed
    }

    private static let shortTimeout: Duration = .milliseconds(100)
    private static let raceDelayMilliseconds: Int = 5
    private static let raceIterationCount: Int = 50

    @Test
    @MainActor func firstValueIsReturned() async throws {

        let value: Int = try await Just(7).awaitFirstValue()

        #expect(value == 7)
    }

    @Test
    @MainActor func synchronouslyPublishedValuesAreReturnedInPublicationOrder() async throws {

        let values: [Int] = try await [1, 2, 3].publisher.awaitValues(count: 3)

        #expect(values == [1, 2, 3])
    }

    @Test
    @MainActor func asynchronouslyPublishedValuesAreReturnedInPublicationOrder() async throws {

        let values: [Int] = try await getAsynchronousPublisher(values: [1, 2, 3])
            .awaitValues(count: 3)

        #expect(values == [1, 2, 3])
    }

    @Test
    @MainActor func onlyTheExpectedNumberOfValuesAreReturned() async throws {

        let values: [Int] = try await [1, 2, 3, 4].publisher.awaitValues(count: 2)

        #expect(values == [1, 2])
    }

    @Test
    @MainActor func subscriptionIsCancelledOnceTheExpectedValuesAreReceived() async throws {

        var subscriptionWasCancelled: Bool = false

        let subject = CurrentValueSubject<Int, Never>(1)

        _ = try await subject
            .handleEvents(receiveCancel: {
                subscriptionWasCancelled = true
            })
            .awaitFirstValue()

        #expect(subscriptionWasCancelled)
    }

    @Test
    @MainActor func timingOutReportsHowManyValuesWereReceived() async throws {

        let subject = CurrentValueSubject<Int, Never>(1)

        await #expect(throws: PublisherValuesCollectorError.timedOut(expectedValueCount: 2, receivedValueCount: 1)) {
            try await subject.awaitValues(count: 2, timeout: Self.shortTimeout)
        }
    }

    @Test
    @MainActor func timingOutBeforeAnyValueIsPublishedFails() async throws {

        let subject = PassthroughSubject<Int, Never>()

        await #expect(throws: PublisherValuesCollectorError.timedOut(expectedValueCount: 1, receivedValueCount: 0)) {
            try await subject.awaitFirstValue(timeout: Self.shortTimeout)
        }
    }

    @Test
    @MainActor func finishingBeforeTheExpectedValuesArePublishedFails() async throws {

        await #expect(throws: PublisherValuesCollectorError.finishedBeforeExpectedValues(expectedValueCount: 2, receivedValueCount: 1)) {
            try await [1].publisher.awaitValues(count: 2)
        }

        await #expect(throws: PublisherValuesCollectorError.finishedBeforeExpectedValues(expectedValueCount: 1, receivedValueCount: 0)) {
            try await Empty<Int, Never>().awaitFirstValue()
        }
    }

    @Test
    @MainActor func publisherFailureIsPropagated() async throws {

        await #expect(throws: TestPublisherError.failed) {
            try await Fail<Int, TestPublisherError>(error: .failed).awaitFirstValue()
        }
    }

    @Test
    @MainActor func whileObservingRunsAfterTheFirstValueIsReceived() async throws {

        let notificationName = Notification.Name(UUID().uuidString)

        let values: [Int] = try await getNotificationPublisher(notificationName: notificationName)
            .awaitValues(count: 2, whileObserving: {
                NotificationCenter.default.post(name: notificationName, object: nil)
            })

        #expect(values == [1, 2])
    }

    @Test
    @MainActor func whileObservingFailureIsPropagated() async throws {

        let notificationName = Notification.Name(UUID().uuidString)

        await #expect(throws: TestPublisherError.failed) {
            try await getNotificationPublisher(notificationName: notificationName)
                .awaitValues(count: 2, whileObserving: {
                    throw TestPublisherError.failed
                })
        }
    }

    @Test
    @MainActor func cancellingBeforeTheWaitStartsThrowsCancellationError() async {

        let waitTask: Task<Int, Error> = Task { @MainActor in
            try await PassthroughSubject<Int, Never>().awaitFirstValue()
        }

        waitTask.cancel()

        await #expect(throws: CancellationError.self) {
            try await waitTask.value
        }
    }

    @Test
    @MainActor func cancellingWhileWaitingForAValueThrowsCancellationError() async {

        let (subscribedStream, subscribedContinuation): (AsyncStream<Void>, AsyncStream<Void>.Continuation) = AsyncStream.makeStream(of: Void.self)

        let waitTask: Task<Int, Error> = Task { @MainActor in
            try await PassthroughSubject<Int, Never>()
                .handleEvents(receiveSubscription: { _ in
                    subscribedContinuation.yield()
                })
                .awaitFirstValue()
        }

        for await _ in subscribedStream {
            break
        }

        waitTask.cancel()

        await #expect(throws: CancellationError.self) {
            try await waitTask.value
        }
    }

    @Test
    @MainActor func racingAValueAgainstTheTimeoutResumesExactlyOnce() async {

        for _ in 0 ..< Self.raceIterationCount {

            do {

                let value: Int = try await Just(1)
                    .delay(for: .milliseconds(Self.raceDelayMilliseconds), scheduler: DispatchQueue.global())
                    .awaitFirstValue(timeout: .milliseconds(Self.raceDelayMilliseconds))

                #expect(value == 1)
            }
            catch let error {

                #expect((error as? PublisherValuesCollectorError) == .timedOut(expectedValueCount: 1, receivedValueCount: 0))
            }
        }
    }
}

// MARK: - Test Helpers

extension PublisherValuesCollectorTests {

    private func getAsynchronousPublisher(values: [Int]) -> AnyPublisher<Int, Never> {

        return values
            .publisher
            .flatMap(maxPublishers: .max(1)) { (value: Int) in
                Just(value)
                    .delay(for: .milliseconds(10), scheduler: DispatchQueue.global())
            }
            .eraseToAnyPublisher()
    }

    private func getNotificationPublisher(notificationName: Notification.Name) -> AnyPublisher<Int, Never> {

        let valuePostedByNotification: AnyPublisher<Int, Never> = NotificationCenter.default
            .publisher(for: notificationName)
            .map { (notification: Notification) in
                return 2
            }
            .eraseToAnyPublisher()

        return Publishers.Merge(valuePostedByNotification, Just(1))
            .eraseToAnyPublisher()
    }
}
