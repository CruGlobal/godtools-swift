//
//  StarscreamWebSocket.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Starscream
import Combine

class StarscreamWebSocket: NSObject, WebSocketInterface {
        
    private let didReceiveTextSubject: PassthroughSubject<String, Never> = PassthroughSubject()
    
    private var socket: WebSocket?
    private var didConnectSubject: PassthroughSubject<Void, Error>?
    
    private(set) var isConnected: Bool = false
        
    override init() {
        super.init()
    }
    
    deinit {
        socket?.disconnect()
    }
    
    var didReceiveTextPublisher: AnyPublisher<String, Never> {
        return didReceiveTextSubject
            .eraseToAnyPublisher()
    }
    
    func connectPublisher(url: URL) -> AnyPublisher<Void, Error> {
        
        guard !isConnected else {
            let error: Error = NSError.errorWithDescription(description: "Is connected or attempting connection.")
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        let didConnectSubject: PassthroughSubject<Void, Error> = PassthroughSubject()
        
        self.didConnectSubject = didConnectSubject
        
        socket = WebSocket(request: URLRequest(url: url))
        socket?.onEvent = { [weak self] event in
            self?.handleWebSocketEvent(event: event)
        }
        socket?.connect()
        
        return didConnectSubject
            .eraseToAnyPublisher()
    }
    
    func disconnect() {
        isConnected = false
        socket?.disconnect()
    }
    
    func write(string: String) {
        socket?.write(string: string)
    }
}

// MARK: - Events

extension StarscreamWebSocket {
    
    private func handleWebSocketEvent(event: WebSocketEvent) {
                
        switch event {
        
        case .connected( _):
            isConnected = true
            
            didConnectSubject?.send(completion: .finished)
            didConnectSubject = nil
        
        case .disconnected( _, _):
            isConnected = false
        
        case .text(let string):
            didReceiveTextSubject.send(string)
        
        case .binary( _):
            break
        
        case .ping(_):
            break
            
        case .peerClosed:
            break
        
        case .pong(_):
            break
        
        case .viabilityChanged( _):
            break
        
        case .reconnectSuggested( _):
            break
        
        case .cancelled:
            isConnected = false
        
        case .error( _):
            isConnected = false
            break
        }
    }
}
