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
        
    private let didConnectSubject: PassthroughSubject<Void, Never> = PassthroughSubject()
    private let didReceiveTextSubject: PassthroughSubject<String, Never> = PassthroughSubject()
    
    private var socket: WebSocket?
    
    private(set) var connectionState: WebSocketConnectionState = .disconnected
        
    let url: URL
    
    required init(url: URL) {
        
        self.url = url
        
        super.init()
    }
    
    deinit {
        socket?.disconnect()
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
        
        disconnect()
        
        connectionState = .connecting
                
        socket = WebSocket(request: URLRequest(url: url))
        socket?.onEvent = { [weak self] event in
            self?.handleWebSocketEvent(event: event)
        }
        socket?.connect()
    }
    
    func disconnect() {
        connectionState = .disconnected
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
            connectionState = .connected
            didConnectSubject.send(Void())
        
        case .disconnected( _, _):
            connectionState = .disconnected
        
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
            break
        
        case .error( _):
            break
        }
    }
}
