//
//  PublisherValuesCollector.swift
//  godtoolsTests
//
//  Created by Claude on 9/24/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class PublisherValuesCollector<Output>: @unchecked Sendable {

    private enum FinishReason {
        case receivedExpectedValues
        case timedOut
        case publisherFinished
        case failed(error: Error)
        case cancelled
    }

    private let expectedValueCount: Int
    private let whileObserving: (@Sendable () async throws -> Void)?
    private let lock: NSLock = NSLock()

    private var values: [Output] = Array()
    private var continuation: CheckedContinuation<[Output], Error>?
    private var pendingResult: Result<[Output], Error>?
    private var isFinished: Bool = false
    private var cancellable: AnyCancellable?
    private var timeoutTask: Task<Void, Never>?
    private var whileObservingTask: Task<Void, Never>?

    init(expectedValueCount: Int, whileObserving: (@Sendable () async throws -> Void)?) {

        self.expectedValueCount = expectedValueCount
        self.whileObserving = whileObserving
    }

    @MainActor func collect<P: Publisher>(from publisher: P, timeout: Duration) async throws -> [Output] where P.Output == Output {

        return try await withTaskCancellationHandler {

            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[Output], Error>) in

                start(publisher: publisher, timeout: timeout, continuation: continuation)
            }
        } onCancel: {

            finish(reason: .cancelled)
        }
    }

    private func start<P: Publisher>(publisher: P, timeout: Duration, continuation: CheckedContinuation<[Output], Error>) where P.Output == Output {

        lock.lock()

        if let pendingResult = pendingResult {

            lock.unlock()
            continuation.resume(with: pendingResult)
            return
        }

        self.continuation = continuation

        lock.unlock()

        let timeoutTask: Task<Void, Never> = Task { [weak self] in

            do {
                try await Task.sleep(for: timeout)
            }
            catch {
                return
            }

            self?.finish(reason: .timedOut)
        }

        let cancellable: AnyCancellable = publisher
            .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<P.Failure>) in

                switch completion {

                case .finished:
                    self?.finish(reason: .publisherFinished)

                case .failure(let error):
                    self?.finish(reason: .failed(error: error))
                }
            }, receiveValue: { [weak self] (value: Output) in

                self?.receive(value: value)
            })

        storeUnlessFinished(timeoutTask: timeoutTask, cancellable: cancellable)
    }

    private func storeUnlessFinished(timeoutTask: Task<Void, Never>, cancellable: AnyCancellable) {

        lock.lock()

        let isFinished: Bool = self.isFinished

        if !isFinished {
            self.timeoutTask = timeoutTask
            self.cancellable = cancellable
        }

        lock.unlock()

        if isFinished {
            timeoutTask.cancel()
            cancellable.cancel()
        }
    }

    private func receive(value: Output) {

        lock.lock()

        guard !isFinished else {
            lock.unlock()
            return
        }

        values.append(value)

        let receivedValueCount: Int = values.count

        lock.unlock()

        if receivedValueCount >= expectedValueCount {
            finish(reason: .receivedExpectedValues)
        }
        else if receivedValueCount == 1 {
            startWhileObserving()
        }
    }

    private func startWhileObserving() {

        guard let whileObserving = whileObserving else {
            return
        }

        let whileObservingTask: Task<Void, Never> = Task { [weak self] in

            do {
                try await whileObserving()
            }
            catch let error {
                self?.finish(reason: .failed(error: error))
            }
        }

        lock.lock()

        let isFinished: Bool = self.isFinished

        if !isFinished {
            self.whileObservingTask = whileObservingTask
        }

        lock.unlock()

        if isFinished {
            whileObservingTask.cancel()
        }
    }

    private func finish(reason: FinishReason) {

        lock.lock()

        guard !isFinished else {
            lock.unlock()
            return
        }

        isFinished = true

        let result: Result<[Output], Error> = getResult(reason: reason)
        let continuation: CheckedContinuation<[Output], Error>? = self.continuation
        let cancellable: AnyCancellable? = self.cancellable
        let timeoutTask: Task<Void, Never>? = self.timeoutTask
        let whileObservingTask: Task<Void, Never>? = self.whileObservingTask

        self.continuation = nil
        self.cancellable = nil
        self.timeoutTask = nil
        self.whileObservingTask = nil

        if continuation == nil {
            pendingResult = result
        }

        lock.unlock()

        cancellable?.cancel()
        timeoutTask?.cancel()
        whileObservingTask?.cancel()
        continuation?.resume(with: result)
    }

    private func getResult(reason: FinishReason) -> Result<[Output], Error> {

        switch reason {

        case .receivedExpectedValues:
            return .success(Array(values.prefix(expectedValueCount)))

        case .timedOut:
            return .failure(PublisherValuesCollectorError.timedOut(expectedValueCount: expectedValueCount, receivedValueCount: values.count))

        case .publisherFinished:
            return .failure(PublisherValuesCollectorError.finishedBeforeExpectedValues(expectedValueCount: expectedValueCount, receivedValueCount: values.count))

        case .failed(let error):
            return .failure(error)

        case .cancelled:
            return .failure(CancellationError())
        }
    }
}
