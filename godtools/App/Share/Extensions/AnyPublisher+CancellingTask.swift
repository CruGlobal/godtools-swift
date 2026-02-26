//
//  AnyPublisher+CancellingTask.swift
//  godtools
//
//  Created by Levi Eggert on 2/14/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

// Found in Stackoverflow a way to cancel a task within a Publisher (https://stackoverflow.com/questions/75880154/cancel-task-inside-future-async-await-with-combine).
// Confirmed the task will cancel when the AnyCancellable reference is removed.

extension AnyPublisher where Failure: Error {
    
    struct Subscriber: Sendable {
    
        fileprivate let send: @Sendable (Output) -> Void
        fileprivate let complete: @Sendable (Subscribers.Completion<Failure>) -> Void

        func send(_ value: Output) { self.send(value) }
        func send(completion: Subscribers.Completion<Failure>) { self.complete(completion) }
    }

    init(_ closure: (Subscriber) -> AnyCancellable) {
        
        nonisolated(unsafe) let subject = PassthroughSubject<Output, Failure>()

        let subscriber = Subscriber(
            send: { subject.send($0) },
            complete: { subject.send(completion: $0) }
        )
        
        let cancel = closure(subscriber)

        self = subject
            .handleEvents(receiveCancel: cancel.cancel)
            .eraseToAnyPublisher()
    }
}

extension AnyPublisher where Failure == Error {
    init(asyncFunc: @escaping () async throws -> Output) {
        self.init { subscriber in
            let task = Task {
                do {
                    subscriber.send(try await asyncFunc())
                    subscriber.send(completion: .finished)
                } catch {
                    subscriber.send(completion: .failure(error))
                }
            }
            return AnyCancellable { task.cancel() }
        }
    }
}
