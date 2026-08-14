//
//  URLSessionWebSocketTaskDelegate.swift
//  godtools
//
//  Created by Levi Eggert on 8/14/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class URLSessionWebSocketTaskDelegate: NSObject, URLSessionWebSocketDelegate, Sendable {

    private let didOpen: @Sendable () -> Void
    private let didClose: @Sendable (_ closeCode: URLSessionWebSocketTask.CloseCode, _ reason: Data?) -> Void
    private let didComplete: @Sendable (_ error: (any Error)?) -> Void

    init(
        didOpen: @escaping @Sendable () -> Void,
        didClose: @escaping @Sendable (_ closeCode: URLSessionWebSocketTask.CloseCode, _ reason: Data?) -> Void,
        didComplete: @escaping @Sendable (_ error: (any Error)?) -> Void
    ) {

        self.didOpen = didOpen
        self.didClose = didClose
        self.didComplete = didComplete

        super.init()
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        
        didOpen()
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        
        didClose(closeCode, reason)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        
        didComplete(error)
    }
}
