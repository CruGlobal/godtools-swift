//
//  MultiBroadcastThrowingStreamTests.swift
//  godtools
//
//  Created by Levi Eggert on 8/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools

private enum MultiBroadcastThrowingStreamTestError: Error, Equatable {
    
    case firstError
    case secondError
}

private struct MultiBroadcastThrowingStreamOutcome: Sendable, Equatable {
    
    let values: [Int]
    let error: MultiBroadcastThrowingStreamTestError?
}

struct MultiBroadcastThrowingStreamTests {
    
    private static let timeoutNanoseconds: UInt64 = 5_000_000_000
    
    @Test()
    func streamReceivesValuesInTheOrderTheyWereSent() async {
        
        let broadcastStream: MultiBroadcastThrowingStream<Int> = MultiBroadcastThrowingStream()
        
        let stream: AsyncThrowingStream<Int, Error> = await broadcastStream.getNewStream()
        
        await broadcastStream.send(value: 1)
        await broadcastStream.send(value: 2)
        await broadcastStream.send(value: 3)
        
        let outcome: MultiBroadcastThrowingStreamOutcome = await collectOutcome(from: stream, untilCount: 3)
        
        #expect(outcome.values == [1, 2, 3])
        #expect(outcome.error == nil)
    }
    
    @Test()
    func streamReceivesInitialSendValueBeforeAnyBroadcastValues() async {
        
        let broadcastStream: MultiBroadcastThrowingStream<Int> = MultiBroadcastThrowingStream()
        
        let stream: AsyncThrowingStream<Int, Error> = await broadcastStream.getNewStream(sendValue: 10)
        
        await broadcastStream.send(value: 20)
        
        let outcome: MultiBroadcastThrowingStreamOutcome = await collectOutcome(from: stream, untilCount: 2)
        
        #expect(outcome.values == [10, 20])
    }
    
    @Test()
    func initialSendValueIsOnlyReceivedByTheNewStream() async {
        
        let broadcastStream: MultiBroadcastThrowingStream<Int> = MultiBroadcastThrowingStream()
        
        let existingStream: AsyncThrowingStream<Int, Error> = await broadcastStream.getNewStream()
        let newStream: AsyncThrowingStream<Int, Error> = await broadcastStream.getNewStream(sendValue: 10)
        
        await broadcastStream.send(value: 20)
        
        let existingStreamOutcome: MultiBroadcastThrowingStreamOutcome = await collectOutcome(from: existingStream, untilCount: 1)
        let newStreamOutcome: MultiBroadcastThrowingStreamOutcome = await collectOutcome(from: newStream, untilCount: 2)
        
        #expect(existingStreamOutcome.values == [20])
        #expect(newStreamOutcome.values == [10, 20])
    }
    
    @Test()
    func allStreamsReceiveBroadcastValues() async {
        
        let broadcastStream: MultiBroadcastThrowingStream<Int> = MultiBroadcastThrowingStream()
        
        let firstStream: AsyncThrowingStream<Int, Error> = await broadcastStream.getNewStream()
        let secondStream: AsyncThrowingStream<Int, Error> = await broadcastStream.getNewStream()
        let thirdStream: AsyncThrowingStream<Int, Error> = await broadcastStream.getNewStream()
        
        await broadcastStream.send(value: 1)
        await broadcastStream.send(value: 2)
        
        let firstStreamOutcome: MultiBroadcastThrowingStreamOutcome = await collectOutcome(from: firstStream, untilCount: 2)
        let secondStreamOutcome: MultiBroadcastThrowingStreamOutcome = await collectOutcome(from: secondStream, untilCount: 2)
        let thirdStreamOutcome: MultiBroadcastThrowingStreamOutcome = await collectOutcome(from: thirdStream, untilCount: 2)
        
        #expect(firstStreamOutcome.values == [1, 2])
        #expect(secondStreamOutcome.values == [1, 2])
        #expect(thirdStreamOutcome.values == [1, 2])
    }
    
    @Test()
    func streamDoesNotReceiveValuesSentBeforeItWasCreated() async {
        
        let broadcastStream: MultiBroadcastThrowingStream<Int> = MultiBroadcastThrowingStream()
        
        await broadcastStream.send(value: 1)
        
        let stream: AsyncThrowingStream<Int, Error> = await broadcastStream.getNewStream()
        
        await broadcastStream.send(value: 2)
        
        let outcome: MultiBroadcastThrowingStreamOutcome = await collectOutcome(from: stream, untilCount: 1)
        
        #expect(outcome.values == [2])
    }
    
    @Test()
    func terminatingOneStreamDoesNotAffectRemainingStreams() async {
        
        let broadcastStream: MultiBroadcastThrowingStream<Int> = MultiBroadcastThrowingStream()
        
        let terminatedStream: AsyncThrowingStream<Int, Error> = await broadcastStream.getNewStream()
        let remainingStream: AsyncThrowingStream<Int, Error> = await broadcastStream.getNewStream()
        
        await broadcastStream.send(value: 1)
        
        let terminatedStreamOutcome: MultiBroadcastThrowingStreamOutcome = await collectOutcome(from: terminatedStream, untilCount: 1)
        
        await broadcastStream.send(value: 2)
        
        let remainingStreamOutcome: MultiBroadcastThrowingStreamOutcome = await collectOutcome(from: remainingStream, untilCount: 2)
        
        #expect(terminatedStreamOutcome.values == [1])
        #expect(remainingStreamOutcome.values == [1, 2])
    }
    
    @Test()
    func allStreamsThrowTheSentError() async {
        
        let broadcastStream: MultiBroadcastThrowingStream<Int> = MultiBroadcastThrowingStream()
        
        let firstStream: AsyncThrowingStream<Int, Error> = await broadcastStream.getNewStream()
        let secondStream: AsyncThrowingStream<Int, Error> = await broadcastStream.getNewStream()
        
        await broadcastStream.send(error: MultiBroadcastThrowingStreamTestError.firstError)
        
        let firstStreamOutcome: MultiBroadcastThrowingStreamOutcome = await collectOutcome(from: firstStream)
        let secondStreamOutcome: MultiBroadcastThrowingStreamOutcome = await collectOutcome(from: secondStream)
        
        #expect(firstStreamOutcome == MultiBroadcastThrowingStreamOutcome(values: [], error: .firstError))
        #expect(secondStreamOutcome == MultiBroadcastThrowingStreamOutcome(values: [], error: .firstError))
    }
    
    @Test()
    func streamReceivesValuesSentBeforeTheError() async {
        
        let broadcastStream: MultiBroadcastThrowingStream<Int> = MultiBroadcastThrowingStream()
        
        let stream: AsyncThrowingStream<Int, Error> = await broadcastStream.getNewStream(sendValue: 1)
        
        await broadcastStream.send(value: 2)
        await broadcastStream.send(error: MultiBroadcastThrowingStreamTestError.firstError)
        
        let outcome: MultiBroadcastThrowingStreamOutcome = await collectOutcome(from: stream)
        
        #expect(outcome == MultiBroadcastThrowingStreamOutcome(values: [1, 2], error: .firstError))
    }
    
    @Test()
    func streamsCreatedAfterAnErrorReceiveNewValues() async {
        
        let broadcastStream: MultiBroadcastThrowingStream<Int> = MultiBroadcastThrowingStream()
        
        let erroredStream: AsyncThrowingStream<Int, Error> = await broadcastStream.getNewStream()
        
        await broadcastStream.send(error: MultiBroadcastThrowingStreamTestError.firstError)
        
        let erroredStreamOutcome: MultiBroadcastThrowingStreamOutcome = await collectOutcome(from: erroredStream)
        
        let newStream: AsyncThrowingStream<Int, Error> = await broadcastStream.getNewStream(sendValue: 1)
        
        await broadcastStream.send(value: 2)
        
        let newStreamOutcome: MultiBroadcastThrowingStreamOutcome = await collectOutcome(from: newStream, untilCount: 2)
        
        #expect(erroredStreamOutcome.error == .firstError)
        #expect(newStreamOutcome == MultiBroadcastThrowingStreamOutcome(values: [1, 2], error: nil))
    }
    
    @Test()
    func onlyTheFirstErrorIsThrownWhenMultipleErrorsAreSent() async {
        
        let broadcastStream: MultiBroadcastThrowingStream<Int> = MultiBroadcastThrowingStream()
        
        let stream: AsyncThrowingStream<Int, Error> = await broadcastStream.getNewStream()
        
        await broadcastStream.send(error: MultiBroadcastThrowingStreamTestError.firstError)
        await broadcastStream.send(error: MultiBroadcastThrowingStreamTestError.secondError)
        
        let outcome: MultiBroadcastThrowingStreamOutcome = await collectOutcome(from: stream)
        
        #expect(outcome.error == .firstError)
    }
    
    @Test()
    func streamsFinishWhenBroadcastStreamIsDeallocated() async {
        
        var broadcastStream: MultiBroadcastThrowingStream<Int>? = MultiBroadcastThrowingStream()
        
        let stream: AsyncThrowingStream<Int, Error> = await broadcastStream!.getNewStream(sendValue: 1)
        
        broadcastStream = nil
        
        let outcome: MultiBroadcastThrowingStreamOutcome = await collectOutcome(from: stream)
        
        #expect(outcome == MultiBroadcastThrowingStreamOutcome(values: [1], error: nil))
    }
    
    @Test()
    func streamsAreNotDroppedWhenValuesAreSentConcurrently() async {
        
        let broadcastStream: MultiBroadcastThrowingStream<Int> = MultiBroadcastThrowingStream()
        
        let stream: AsyncThrowingStream<Int, Error> = await broadcastStream.getNewStream()
        
        await withTaskGroup(of: Void.self) { group in
            
            for value in 1 ... 100 {
                
                group.addTask {
                    await broadcastStream.send(value: value)
                }
            }
        }
        
        let outcome: MultiBroadcastThrowingStreamOutcome = await collectOutcome(from: stream, untilCount: 100)
        
        #expect(outcome.values.count == 100)
        #expect(Set(outcome.values) == Set(1 ... 100))
    }
}

// MARK: - Test Helpers

extension MultiBroadcastThrowingStreamTests {
    
    private func collectOutcome(from stream: AsyncThrowingStream<Int, Error>, untilCount count: Int? = nil) async -> MultiBroadcastThrowingStreamOutcome {
        
        return await withTaskGroup(of: MultiBroadcastThrowingStreamOutcome?.self) { group in
            
            group.addTask {
                
                var values: [Int] = Array()
                
                do {
                    
                    for try await value in stream {
                        
                        values.append(value)
                        
                        if let count = count, values.count >= count {
                            break
                        }
                    }
                }
                catch {
                    
                    return MultiBroadcastThrowingStreamOutcome(
                        values: values,
                        error: error as? MultiBroadcastThrowingStreamTestError
                    )
                }
                
                return MultiBroadcastThrowingStreamOutcome(values: values, error: nil)
            }
            
            group.addTask {
                
                do {
                    try await Task.sleep(nanoseconds: Self.timeoutNanoseconds)
                }
                catch {
                    return nil
                }
                
                Issue.record("Timed out waiting for stream values.")
                
                return nil
            }
            
            let outcome: MultiBroadcastThrowingStreamOutcome? = await group.next() ?? nil
            
            group.cancelAll()
            
            return outcome ?? MultiBroadcastThrowingStreamOutcome(values: Array(), error: nil)
        }
    }
}
