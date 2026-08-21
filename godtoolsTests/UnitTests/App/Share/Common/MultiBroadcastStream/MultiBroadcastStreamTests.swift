//
//  MultiBroadcastStreamTests.swift
//  godtools
//
//  Created by Levi Eggert on 8/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools

struct MultiBroadcastStreamTests {
    
    private static let timeoutNanoseconds: UInt64 = 5_000_000_000
    
    @Test()
    func streamReceivesValuesInTheOrderTheyWereSent() async {
        
        let broadcastStream: MultiBroadcastStream<Int> = MultiBroadcastStream()
        
        let stream: AsyncStream<Int> = await broadcastStream.getNewStream()
        
        await broadcastStream.send(value: 1)
        await broadcastStream.send(value: 2)
        await broadcastStream.send(value: 3)
        
        let values: [Int] = await collectValues(from: stream, untilCount: 3)
        
        #expect(values == [1, 2, 3])
    }
    
    @Test()
    func streamReceivesInitialSendValueBeforeAnyBroadcastValues() async {
        
        let broadcastStream: MultiBroadcastStream<Int> = MultiBroadcastStream()
        
        let stream: AsyncStream<Int> = await broadcastStream.getNewStream(sendValue: 10)
        
        await broadcastStream.send(value: 20)
        
        let values: [Int] = await collectValues(from: stream, untilCount: 2)
        
        #expect(values == [10, 20])
    }
    
    @Test()
    func initialSendValueIsOnlyReceivedByTheNewStream() async {
        
        let broadcastStream: MultiBroadcastStream<Int> = MultiBroadcastStream()
        
        let existingStream: AsyncStream<Int> = await broadcastStream.getNewStream()
        let newStream: AsyncStream<Int> = await broadcastStream.getNewStream(sendValue: 10)
        
        await broadcastStream.send(value: 20)
        
        let existingStreamValues: [Int] = await collectValues(from: existingStream, untilCount: 1)
        let newStreamValues: [Int] = await collectValues(from: newStream, untilCount: 2)
        
        #expect(existingStreamValues == [20])
        #expect(newStreamValues == [10, 20])
    }
    
    @Test()
    func allStreamsReceiveBroadcastValues() async {
        
        let broadcastStream: MultiBroadcastStream<Int> = MultiBroadcastStream()
        
        let firstStream: AsyncStream<Int> = await broadcastStream.getNewStream()
        let secondStream: AsyncStream<Int> = await broadcastStream.getNewStream()
        let thirdStream: AsyncStream<Int> = await broadcastStream.getNewStream()
        
        await broadcastStream.send(value: 1)
        await broadcastStream.send(value: 2)
        
        let firstStreamValues: [Int] = await collectValues(from: firstStream, untilCount: 2)
        let secondStreamValues: [Int] = await collectValues(from: secondStream, untilCount: 2)
        let thirdStreamValues: [Int] = await collectValues(from: thirdStream, untilCount: 2)
        
        #expect(firstStreamValues == [1, 2])
        #expect(secondStreamValues == [1, 2])
        #expect(thirdStreamValues == [1, 2])
    }
    
    @Test()
    func streamDoesNotReceiveValuesSentBeforeItWasCreated() async {
        
        let broadcastStream: MultiBroadcastStream<Int> = MultiBroadcastStream()
        
        await broadcastStream.send(value: 1)
        
        let stream: AsyncStream<Int> = await broadcastStream.getNewStream()
        
        await broadcastStream.send(value: 2)
        
        let values: [Int] = await collectValues(from: stream, untilCount: 1)
        
        #expect(values == [2])
    }
    
    @Test()
    func terminatingOneStreamDoesNotAffectRemainingStreams() async {
        
        let broadcastStream: MultiBroadcastStream<Int> = MultiBroadcastStream()
        
        let terminatedStream: AsyncStream<Int> = await broadcastStream.getNewStream()
        let remainingStream: AsyncStream<Int> = await broadcastStream.getNewStream()
        
        await broadcastStream.send(value: 1)
        
        let terminatedStreamValues: [Int] = await collectValues(from: terminatedStream, untilCount: 1)
        
        await broadcastStream.send(value: 2)
        
        let remainingStreamValues: [Int] = await collectValues(from: remainingStream, untilCount: 2)
        
        #expect(terminatedStreamValues == [1])
        #expect(remainingStreamValues == [1, 2])
    }
    
    @Test()
    func sendingValueWithoutAnyStreamsDoesNotAffectFutureStreams() async {
        
        let broadcastStream: MultiBroadcastStream<Int> = MultiBroadcastStream()
        
        await broadcastStream.send(value: 1)
        await broadcastStream.send(value: 2)
        
        let stream: AsyncStream<Int> = await broadcastStream.getNewStream(sendValue: 3)
        
        let values: [Int] = await collectValues(from: stream, untilCount: 1)
        
        #expect(values == [3])
    }
    
    @Test()
    func streamsFinishWhenBroadcastStreamIsDeallocated() async {
        
        var broadcastStream: MultiBroadcastStream<Int>? = MultiBroadcastStream()
        
        let stream: AsyncStream<Int> = await broadcastStream!.getNewStream(sendValue: 1)
        
        broadcastStream = nil
        
        let values: [Int] = await collectValues(from: stream)
        
        #expect(values == [1])
    }
    
    @Test()
    func streamsAreNotDroppedWhenValuesAreSentConcurrently() async {
        
        let broadcastStream: MultiBroadcastStream<Int> = MultiBroadcastStream()
        
        let stream: AsyncStream<Int> = await broadcastStream.getNewStream()
        
        await withTaskGroup(of: Void.self) { group in
            
            for value in 1 ... 100 {
                
                group.addTask {
                    await broadcastStream.send(value: value)
                }
            }
        }
        
        let values: [Int] = await collectValues(from: stream, untilCount: 100)
        
        #expect(values.count == 100)
        #expect(Set(values) == Set(1 ... 100))
    }
}

// MARK: - Test Helpers

extension MultiBroadcastStreamTests {
    
    private func collectValues(from stream: AsyncStream<Int>, untilCount count: Int? = nil) async -> [Int] {
        
        return await withTaskGroup(of: [Int]?.self) { group in
            
            group.addTask {
                
                var values: [Int] = Array()
                
                for await value in stream {
                    
                    values.append(value)
                    
                    if let count = count, values.count >= count {
                        break
                    }
                }
                
                return values
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
            
            let values: [Int]? = await group.next() ?? nil
            
            group.cancelAll()
            
            return values ?? Array()
        }
    }
}
