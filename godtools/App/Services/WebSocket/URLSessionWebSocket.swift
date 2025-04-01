//
//  URLSessionWebSocket.swift
//  godtools
//
//  Created by Levi Eggert on 3/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class URLSessionWebSocket: NSObject, WebSocketInterface {
    
    enum ConnectionState {
        case connecting
        case connected
        case disconnecting
        case disconnected
    }
    
    private let ignoreCacheSession: IgnoreCacheSession = IgnoreCacheSession()
    
    private var session: URLSession {
        return ignoreCacheSession.session
    }
    
    private var currentWebSocketTask: URLSessionWebSocketTask?
    private var keepAliveTimer: Timer?
    
    private(set) var connectionState: ConnectionState = .disconnected
    
    let didConnectSignal: Signal = Signal()
    let didDisconnectSignal: Signal = Signal()
    let didReceiveTextSignal: SignalValue<String> = SignalValue()
    
    override init() {
        super.init()
    }
    
    deinit {
        keepAliveTimer?.invalidate()
        keepAliveTimer = nil
    }
    
    private func keepSocketAlive() {
        
        guard isConnected, let webSocketTask = currentWebSocketTask else {
            return
        }
        
        webSocketTask.sendPing { [weak self] (error: Error?) in
            self?.keepAliveTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] (timer: Timer) in
                self?.keepSocketAlive()
            }
        }
    }
    
    var isConnected: Bool {
        return connectionState == .connected
    }
    
    func connect(url: URL) {
                
        connectionState = .connecting
        
        let webSocketTask: URLSessionWebSocketTask = session.webSocketTask(with: url)
        
        currentWebSocketTask = webSocketTask
        
        receiveNextResult()
        
        webSocketTask.delegate = self
        
        webSocketTask.resume()
    }
    
    func disconnect() {
        
        guard let webSocketTask = currentWebSocketTask else {
            return
        }
        
        connectionState = .disconnecting
        
        keepAliveTimer?.invalidate()
        keepAliveTimer = nil
        
        webSocketTask.cancel(with: .goingAway, reason: nil)
    }
    
    func write(string: String) {
        
        guard let webSocketTask = currentWebSocketTask else {
            return
        }
        
        webSocketTask.send(.string(string), completionHandler: { (error: Error?) in
            
        })
    }
    
    private func receiveNextResult() {
        
        guard let webSocketTask = currentWebSocketTask else {
            return
        }
        
        webSocketTask.receive { [weak self] (result: Result<URLSessionWebSocketTask.Message, any Error>) in
            self?.handleResultReceived(result: result)
            self?.receiveNextResult()
        }
    }
    
    private func handleResultReceived(result: Result<URLSessionWebSocketTask.Message, any Error>) {
                
        switch result {
        case .success(let message):
                        
            switch message {
            case .data( _):
                break
            case .string(let text):
                didReceiveTextSignal.accept(value: text)
            @unknown default:
                break
            }
        case .failure( _):
            break
        }
    }
}

// MARK: - URLSessionWebSocketDelegate

extension URLSessionWebSocket: URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
                
        connectionState = .connected
        
        didConnectSignal.accept()
        
        keepSocketAlive()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
                
        keepAliveTimer?.invalidate()
        keepAliveTimer = nil
        
        connectionState = .disconnected
        currentWebSocketTask = nil
        
        didDisconnectSignal.accept()
    }
}
