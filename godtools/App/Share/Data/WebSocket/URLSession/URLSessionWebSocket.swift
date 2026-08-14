//
//  URLSessionWebSocket.swift
//  godtools
//
//  Created by Levi Eggert on 3/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation

@MainActor
final class URLSessionWebSocket: Sendable {
    
    private let session: URLSession = URLSession(configuration: CreateIgnoreCacheSessionConfig().createConfig())
    private let keepSocketAlive: KeepWebSocketAlive = KeepWebSocketAlive()
    private let messagesObserver: WebSocketMessagesObserver = WebSocketMessagesObserver()
    private let didConnectSubject: PassthroughSubject<Void, Never> = PassthroughSubject()
    private let didReceiveTextSubject: PassthroughSubject<String, Never> = PassthroughSubject()
    
    private var currentWebSocketTask: URLSessionWebSocketTask?
    
    private(set) var connectionState: WebSocketConnectionState = .disconnected
       
    let url: URL
    
    required init(url: URL) {
        
        self.url = url
    }
    
    deinit {
        
        let webSocket = self
        
        Task { @MainActor in
            await webSocket.disconnect()
        }
    }
    
    var didConnectPublisher: AnyPublisher<Void, Never> {
        return didConnectSubject
            .eraseToAnyPublisher()
    }
    
    var didReceiveTextPublisher: AnyPublisher<String, Never> {
        return didReceiveTextSubject
            .eraseToAnyPublisher()
    }
    
    func connect() async {

        guard connectionState != .connected && connectionState != .connecting else {
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
        
        currentWebSocketTask = webSocketTask
        
        await messagesObserver.start(webSocketTask: webSocketTask, messageReceivedClosure: { [weak self] (text: String?, error: Error?) in
            
            if let text = text {
                self?.didReceiveTextSubject.send(text)
            }
        })
                
        webSocketTask.delegate = taskDelegate
        
        webSocketTask.resume()
    }
    
    // MARK: - URLSessionWebSocketDelegate Handling

    private func handleDidOpen() async {

        guard connectionState == .connecting, let webSocketTask = currentWebSocketTask else {
            return
        }

        connectionState = .connected

        didConnectSubject.send(Void())

        await keepSocketAlive.start(webSocketTask: webSocketTask)

        if connectionState != .connected {
            await keepSocketAlive.stop()
        }
    }

    private func handleDidClose(closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) async {

//        let reasonText: String?
//
//        if let reason = reason {
//            reasonText = String(data: reason, encoding: .utf8)
//        }
//        else {
//            reasonText = nil
//        }
//
//        await disconnect(reason: .closedByServer(closeCode: closeCode, reason: reasonText))
    }

    private func handleDidComplete(error: (any Error)?) async {

//        guard connectionState != .disconnected else {
//            return
//        }
//
//        guard let error = error else {
//            await disconnect(reason: .closedByServer(closeCode: .invalid, reason: nil))
//            return
//        }
//
//        await disconnect(reason: .failed(error: .transportFailed(description: error.localizedDescription)))
    }
    
    func disconnect() async {
        
        guard let webSocketTask = currentWebSocketTask else {
            return
        }
        
        connectionState = .disconnected
        
        await keepSocketAlive.stop()
        
        await messagesObserver.stop()
                
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
}
