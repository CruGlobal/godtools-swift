//
//  MultiBroadcastThrowingStream.swift
//  godtools
//
//  Created by Levi Eggert on 8/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

actor MultiBroadcastThrowingStream<Element: Sendable> {
    
    private var continuations: [UUID: AsyncThrowingStream<Element, Error>.Continuation] = Dictionary()
    
    init() {
        
    }
    
    deinit {
        
        for continuation in continuations.values {
            continuation.finish()
        }
    }
    
    private func removeContinuation(continuationId: UUID) {
        
        continuations[continuationId] = nil
    }
    
    func getNewStream(sendValue: Element? = nil) -> AsyncThrowingStream<Element, Error> {
        
        let (stream, continuation) = AsyncThrowingStream<Element, Error>.makeStream()
        let continuationId: UUID = UUID()
        
        continuations[continuationId] = continuation
        
        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeContinuation(continuationId: continuationId) }
        }
        
        if let sendValue = sendValue {
            continuation.yield(sendValue)
        }
        
        return stream
    }
    
    func send(value: Element) {
        
        for continuation in continuations.values {
            continuation.yield(value)
        }
    }
    
    func send(error: Error) {
        
        let continuationsToFinish: [AsyncThrowingStream<Element, Error>.Continuation] = Array(continuations.values)
        
        continuations.removeAll()
        
        for continuation in continuationsToFinish {
            continuation.finish(throwing: error)
        }
    }
}
