//
//  URLSessionWebSocket.swift
//  godtools
//
//  Created by Levi Eggert on 3/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class URLSessionWebSocket: NSObject, WebSocketInterface {
    
    private let ignoreCacheSession: IgnoreCacheSession = IgnoreCacheSession()
    private let didConnectSubject: PassthroughSubject<Void, Never> = PassthroughSubject()
    private let didReceiveTextSubject: PassthroughSubject<String, Never> = PassthroughSubject()
    
    private var session: URLSession {
        return ignoreCacheSession.session
    }
    
    private var currentWebSocketTask: URLSessionWebSocketTask?
    private var keepAliveTimer: Timer?
    
    private(set) var connectionState: WebSocketConnectionState = .disconnected
       
    let url: URL
    
    required init(url: URL) {
        
        self.url = url
        
        super.init()
    }
    
    deinit {
        stopKeepAliveTimer()
    }
    
    private func keepSocketAlive() {
        
        guard connectionState == .connected, let webSocketTask = currentWebSocketTask else {
            return
        }
        
        webSocketTask.sendPing { [weak self] (error: Error?) in
            self?.keepAliveTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] (timer: Timer) in
                self?.keepSocketAlive()
            }
        }
    }
    
    private func stopKeepAliveTimer() {
        keepAliveTimer?.invalidate()
        keepAliveTimer = nil
    }
    
    var didConnectPublisher: AnyPublisher<Void, Never> {
        return didConnectSubject
            .eraseToAnyPublisher()
    }
    
    var didReceiveTextPublisher: AnyPublisher<String, Never> {
        return didReceiveTextSubject
            .eraseToAnyPublisher()
    }
    
    func connect() {

        guard connectionState != .connected && connectionState != .connected else {
            return
        }
        
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
        
        connectionState = .disconnected
        
        stopKeepAliveTimer()
        
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
                didReceiveTextSubject.send(text)
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
                
        if connectionState == .connecting {
         
            connectionState = .connected
                    
            didConnectSubject.send(Void())
            
            keepSocketAlive()
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        // NOTE: For now won't handle anything here.  However, it might be good to monitor changes here and update the user. ~Levi
    }
}
