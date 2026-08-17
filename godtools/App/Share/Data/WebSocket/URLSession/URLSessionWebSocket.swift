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

actor URLSessionWebSocket {
    
    private let session: URLSession = URLSession(configuration: CreateIgnoreCacheSessionConfig().createConfig())
    private let keepSocketAlive: KeepWebSocketAlive = KeepWebSocketAlive()
    private let messagesObserver: WebSocketMessagesObserver = WebSocketMessagesObserver()
    private let didConnectSubject: PassthroughSubject<Void, Never> = PassthroughSubject()
    private let didReceiveTextSubject: PassthroughSubject<String, Never> = PassthroughSubject()
    private let consoleLogger: ConsoleLoggerInterface
    
    private var currentWebSocketTask: URLSessionWebSocketTask?
    private var receiveMessagesTask: Task<Void, Never>?
    
    private(set) var connectionState: WebSocketConnectionState = .disconnected
       
    let url: URL
    
    init(url: URL, consoleLogger: ConsoleLoggerInterface) {
        
        self.url = url
        self.consoleLogger = consoleLogger
    }
    
    deinit {
        
        let webSocket = self
        
        // TODO: Fix. ~Levi
//        Task { @MainActor in
//            await webSocket.disconnect()
//        }
    }
    
    var didConnectPublisher: AnyPublisher<Void, Never> {
        return didConnectSubject
            .eraseToAnyPublisher()
    }
    
    var didReceiveTextPublisher: AnyPublisher<String, Never> {
        return didReceiveTextSubject
            .eraseToAnyPublisher()
    }
    
    private func cancelReceiveMessagesTask() {
        
        receiveMessagesTask?.cancel()
        receiveMessagesTask = nil
    }
    
    func connect() async {

        guard connectionState != .connected && connectionState != .connecting else {
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
        
        let messages: AsyncThrowingStream<String, any Error> = await messagesObserver.start(webSocketTask: webSocketTask)

        cancelReceiveMessagesTask()
        
        receiveMessagesTask = Task { [weak self] in

            do {

                for try await text in messages {
                    
                    self?.consoleLogger.log(message: "did receive text: \(text)")
                    
                    self?.didReceiveTextSubject.send(text)
                }
            }
            catch {

            }
        }

        webSocketTask.delegate = taskDelegate
        
        webSocketTask.resume()
    }
    
    func disconnect() async {
        
        guard let webSocketTask = currentWebSocketTask else {
            return
        }
        
        consoleLogger.log(message: "disconnect")
        
        connectionState = .disconnected
        
        cancelReceiveMessagesTask()
        
        await keepSocketAlive.stop()
        
        await messagesObserver.stop()

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

        guard connectionState == .connecting, let webSocketTask = currentWebSocketTask else {
            return
        }
        
        consoleLogger.log(message: "did open")

        connectionState = .connected

        didConnectSubject.send(Void())

        await keepSocketAlive.start(webSocketTask: webSocketTask)

        if connectionState != .connected {
            await keepSocketAlive.stop()
        }
    }

    private func handleDidClose(closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) async {
        
        consoleLogger.log(message: "did close")

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
        
        await disconnect()
    }

    private func handleDidComplete(error: (any Error)?) async {
        
        consoleLogger.log(message: "did complete with error: \(String(describing: error))")

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
        
        await disconnect()
    }
}
