//
//  StarscreamWebSocket.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Starscream

class StarscreamWebSocket: NSObject, WebSocketType {
        
    private var socket: WebSocket?
    
    private(set) var isConnected: Bool = false
    
    let didConnectSignal: Signal = Signal()
    let didDisconnectSignal: Signal = Signal()
    let didReceiveTextSignal: SignalValue<String> = SignalValue()
    let didReceiveEventSignal: SignalValue<WebSocketEvent> = SignalValue()
    
    override init() {
        super.init()
    }
    
    deinit {
        socket?.disconnect()
    }
    
    func connect(url: URL) {
        
        guard !isConnected else {
            return
        }
        
        socket = WebSocket(request: URLRequest(url: url))
        socket?.onEvent = { [weak self] event in
            self?.handleWebSocketEvent(event: event)
        }
        socket?.connect()
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
        
        didReceiveEventSignal.accept(value: event)
        
        switch event {
        
        case .connected( _):
            isConnected = true
            didConnectSignal.accept()
        
        case .disconnected( _, _):
            isConnected = false
            didDisconnectSignal.accept()
        
        case .text(let string):
            didReceiveTextSignal.accept(value: string)
        
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
