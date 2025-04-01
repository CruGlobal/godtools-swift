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
        case disconnected
    }
    
    private let ignoreCacheSession: IgnoreCacheSession = IgnoreCacheSession()
    
    private var session: URLSession {
        return ignoreCacheSession.session
    }
    
    private var currentWebSocketTask: URLSessionWebSocketTask?
    private var connectionState: ConnectionState = .disconnected
    
    let didConnectSignal: Signal = Signal()
    let didDisconnectSignal: Signal = Signal()
    let didReceiveTextSignal: SignalValue<String> = SignalValue()
    
    override init() {
        super.init()
    }
    
    var isConnected: Bool {
        return connectionState == .connected
    }
    
    func connect(url: URL) {
        
        print("\n Connect to url: \(url.absoluteString)")
        
        guard let wssUrl = URL(string: "wss://mobile-content-api.cru.org/cable") else {
            return
        }
        
        connectionState = .connecting
        
        let webSocketTask: URLSessionWebSocketTask = session.webSocketTask(with: wssUrl)
        
        currentWebSocketTask = webSocketTask
        
        webSocketTask.delegate = self
        
        webSocketTask.receive { [weak self] (result: Result<URLSessionWebSocketTask.Message, any Error>) in
            
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Data received \(data)")
                case .string(let text):
                    print("Text received \(text)")
                    self?.didReceiveTextSignal.accept(value: text)
                @unknown default:
                    break
                }
            case .failure(let error):
                print("Error when receiving \(error)")
            }
        }
        
        webSocketTask.resume()
    }
    
    func disconnect() {
        
        guard let webSocketTask = currentWebSocketTask else {
            return
        }
        
        webSocketTask.cancel(with: .goingAway, reason: nil)
    }
    
    func write(string: String) {
        
        currentWebSocketTask?.send(.string(string), completionHandler: { (error: Error?) in
            
            print("\n Did send string: \(string)")
            print("  error: \(String(describing: error))")
        })
    }
}

// MARK: - URLSessionWebSocketDelegate

extension URLSessionWebSocket: URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        
        print("\n WebSocketTask did open with protocol")
        
        connectionState = .connected
        
        didConnectSignal.accept()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        
        print("\n WebSocketTask did close")
        
        connectionState = .disconnected
        currentWebSocketTask = nil
        
        didDisconnectSignal.accept()
        
        if let data = reason {
            let stringData: String? = String(data: data, encoding: .utf8)
            print("  reason: \(String(describing: stringData))")
        }
    }
}
