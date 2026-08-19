//
//  URLSessionWebSocket.swift
//  godtools
//
//  Created by Levi Eggert on 3/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RequestOperation

actor URLSessionWebSocket: WebSocketInterface {
    
    private let session: URLSession = URLSession(configuration: CreateIgnoreCacheSessionConfig().createConfig())
    private let keepSocketAlive: KeepWebSocketAlive = KeepWebSocketAlive()
    
    private var currentWebSocketTask: URLSessionWebSocketTask?
    private var connectionStateContinuations: [UUID: AsyncStream<WebSocketConnectionState>.Continuation] = Dictionary()
    private var receiveTextContinuations: [UUID: AsyncStream<String>.Continuation] = Dictionary()
    private var receiveTextTask: Task<Void, Never>?
    
    private(set) var connectionState: WebSocketConnectionState = .noState {
        didSet {
            for continuation in connectionStateContinuations.values {
                continuation.yield(connectionState)
            }
        }
    }
           
    var isConnected: Bool {
        return connectionState.isConnected
    }
    
    var isConnecting: Bool {
        return connectionState.isConnecting
    }
    
    func connect(url: URL) async {

        guard !isConnected && !isConnecting else {
            return
        }
        
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
        
        observeTaskReceive(webSocketTask: webSocketTask)
        
        currentWebSocketTask = webSocketTask

        webSocketTask.delegate = taskDelegate
        
        webSocketTask.resume()
    }
    
    func disconnect() async {
        
        await disconnectWithReason(reason: .clientDisconnected)
    }
    
    private func disconnectWithReason(reason: WebSocketDisconnectedReason) async {
        
        guard let webSocketTask = currentWebSocketTask else {
            return
        }
        
        connectionState = .disconnected(reason: .clientDisconnected)
        
        cancelObserveTaskReceive()
                
        await keepSocketAlive.stop()
        
        webSocketTask.cancel(with: .goingAway, reason: nil)

        currentWebSocketTask = nil
    }
    
    func write(string: String) {
        
        guard let webSocketTask = currentWebSocketTask else {
            return
        }
        
        webSocketTask.send(.string(string), completionHandler: { (error: Error?) in
            
        })
    }
    
    // MARK: - URLSessionWebSocketDelegate Handling

    private func handleDidOpen() async {

        guard connectionState.isConnecting, let webSocketTask = currentWebSocketTask else {
            return
        }
        
        connectionState = .connected

        await keepSocketAlive.start(webSocketTask: webSocketTask)

        if !connectionState.isConnected {
            await keepSocketAlive.stop()
        }
    }

    private func handleDidClose(closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) async {
        
        let reasonString: String?
        
        if let reason = reason {
            reasonString = String(data: reason, encoding: .utf8)
        }
        else {
            reasonString = nil
        }
        
        await disconnectWithReason(reason: .didClose(reason: reasonString))
    }

    private func handleDidComplete(error: (any Error)?) async {
        
        await disconnectWithReason(reason: .taskFinishedTransfer(failure: error?.localizedDescription))
    }
}

// MARK: - Streams

extension URLSessionWebSocket {
    
    func getConnectionStateStream() -> AsyncStream<WebSocketConnectionState> {
        
        let (stream, continuation) = AsyncStream<WebSocketConnectionState>.makeStream()
        let continuationId: UUID = UUID()
        
        connectionStateContinuations[continuationId] = continuation
        
        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeConnectionStateContinuation(continuationId: continuationId) }
        }
        
        continuation.yield(connectionState)
        
        return stream
    }
    
    private func removeConnectionStateContinuation(continuationId: UUID) {
        
        connectionStateContinuations[continuationId] = nil
    }
    
    func getTextStream() -> AsyncStream<String> {
        
        let (stream, continuation) = AsyncStream<String>.makeStream()
        let continuationId: UUID = UUID()
        
        receiveTextContinuations[continuationId] = continuation
        
        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeReceiveTextContinuation(continuationId: continuationId) }
        }
                
        return stream
    }
    
    private func removeReceiveTextContinuation(continuationId: UUID) {
        
        receiveTextContinuations[continuationId] = nil
    }
    
    private func sendText(text: String) {
        
        for continuation in receiveTextContinuations.values {
            continuation.yield(text)
        }
    }
    
    private func cancelObserveTaskReceive() {
        receiveTextTask?.cancel()
        receiveTextTask = nil
    }
    
    private func observeTaskReceive(webSocketTask: URLSessionWebSocketTask) {

        cancelObserveTaskReceive()

        receiveTextTask = Task { [weak self] in
            
            while !Task.isCancelled {
                
                do {
                    
                    let message: URLSessionWebSocketTask.Message = try await webSocketTask.receive()
                    
                    guard let text = await self?.getTextFromMessage(message: message) else {
                        continue
                    }
                    
                    await self?.sendText(text: text)
                }
                catch let error {
                    // TODO: Handle error? ~Levi
                    break
                }
            }
        }
    }
    
    private func getTextFromMessage(message: URLSessionWebSocketTask.Message) -> String? {
        
        switch message {
        case .string(let text):
            return text
        default:
            return nil
        }
    }
}
