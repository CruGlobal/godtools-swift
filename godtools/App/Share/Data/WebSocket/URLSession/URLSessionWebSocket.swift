//
//  URLSessionWebSocket.swift
//  godtools
//
//  Created by Levi Eggert on 3/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RequestOperation

actor URLSessionWebSocket {
    
    private let session: URLSession = URLSession(configuration: CreateIgnoreCacheSessionConfig().createConfig())
    private let keepSocketAlive: KeepWebSocketAlive = KeepWebSocketAlive()
    private let consoleLogger: ConsoleLoggerInterface
    
    private var currentWebSocketTask: URLSessionWebSocketTask?
    
    private(set) var connectionState: WebSocketConnectionState = .noState
           
    init(consoleLogger: ConsoleLoggerInterface) {
        
        self.consoleLogger = consoleLogger
    }
    
    var isConnected: Bool {
        return connectionState.isConnected
    }
    
    var isConnecting: Bool {
        return connectionState.isConnecting
    }
    
    func getReceiveTextStream() async -> AsyncThrowingStream<String, any Error>? {
        
        guard let task = currentWebSocketTask else {
            return nil
        }
        
        return await WebSocketMessagesObserver().start(webSocketTask: task)
    }
    
    func connect(url: URL) async {

        guard !isConnected && !isConnecting else {
            return
        }
        
        consoleLogger.log(message: "connect")
        
        connectionState = .connecting
        
        let taskDelegate: URLSessionWebSocketTaskDelegate = URLSessionWebSocketTaskDelegate(
            didOpen: { [weak self] in
                Task { await self?.handleDidOpen() }
            },
            didClose: { [weak self] (closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) in
                Task { await self?.handleDidClose(closeCode: closeCode, reason: reason) }
            },
            didComplete: { [weak self] (error: (any Error)?) in
                Task { await self?.handleDidComplete(error: error) }
            }
        )
                        
        let webSocketTask: URLSessionWebSocketTask = session.webSocketTask(with: url)
        
        currentWebSocketTask = webSocketTask

        webSocketTask.delegate = taskDelegate
        
        webSocketTask.resume()
    }
    
    func disconnect(reason: WebSocketDisconnectedReason? = nil) async {
        
        guard let webSocketTask = currentWebSocketTask else {
            return
        }
        
        consoleLogger.log(message: "disconnect")
        
        connectionState = .disconnected(reason: .clientDisconnected)
                
        await keepSocketAlive.stop()
        
        webSocketTask.cancel(with: .goingAway, reason: nil)

        currentWebSocketTask = nil
    }
    
    func write(string: String) {
        
        guard let webSocketTask = currentWebSocketTask else {
            return
        }
        
        consoleLogger.log(message: "write string: \(string)")
        
        webSocketTask.send(.string(string), completionHandler: { (error: Error?) in
            
        })
    }
    
    // MARK: - URLSessionWebSocketDelegate Handling

    private func handleDidOpen() async {

        guard connectionState.isConnecting, let webSocketTask = currentWebSocketTask else {
            return
        }
        
        consoleLogger.log(message: "did open")

        connectionState = .connected

        await keepSocketAlive.start(webSocketTask: webSocketTask)

        if !connectionState.isConnected {
            await keepSocketAlive.stop()
        }
    }

    private func handleDidClose(closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) async {
        
        consoleLogger.log(message: "did close")

        let reasonString: String?
        
        if let reason = reason {
            reasonString = String(data: reason, encoding: .utf8)
        }
        else {
            reasonString = nil
        }
        
        await disconnect(reason: .didClose(reason: reasonString))
    }

    private func handleDidComplete(error: (any Error)?) async {
        
        consoleLogger.log(message: "did complete with error: \(String(describing: error))")

        await disconnect(reason: .taskFinishedTransfer(failure: error?.localizedDescription))
    }
}
