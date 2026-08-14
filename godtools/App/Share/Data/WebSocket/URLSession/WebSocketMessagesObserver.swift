//
//  WebSocketMessagesObserver.swift
//  godtools
//
//  Created by Levi Eggert on 8/14/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

actor WebSocketMessagesObserver {

    private var receiveMessagesTask: Task<Void, Never>?

    func start(webSocketTask: URLSessionWebSocketTask) -> AsyncThrowingStream<String, any Error> {

        stop()

        return AsyncThrowingStream { (continuation: AsyncThrowingStream<String, any Error>.Continuation) in

            receiveMessagesTask = Task {

                do {

                    while !Task.isCancelled {

                        let message: URLSessionWebSocketTask.Message = try await webSocketTask.receive()

                        guard case .string(let text) = message else {
                            continue
                        }

                        continuation.yield(text)
                    }

                    continuation.finish()
                }
                catch {

                    guard !Task.isCancelled else {
                        continuation.finish()
                        return
                    }

                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { [weak self] _ in
                Task { [weak self] in
                    await self?.stop()
                }
            }
        }
    }

    func stop() {

        receiveMessagesTask?.cancel()
        receiveMessagesTask = nil
    }
}
