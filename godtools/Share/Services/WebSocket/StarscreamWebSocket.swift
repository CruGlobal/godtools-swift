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
    
    private let remoteUrl: URL
    
    private var socket: WebSocket?
    
    private(set) var isConnected: Bool = false
    
    let didConnectSignal: Signal = Signal()
    let didDisconnectSignal: Signal = Signal()
    let didReceiveTextSignal: SignalValue<String> = SignalValue()
    let didReceiveJsonSignal: SignalValue<[String : Any]> = SignalValue()
    let didReceiveEventSignal: SignalValue<WebSocketEvent> = SignalValue()
    
    required init(config: ConfigType) {
        
        remoteUrl = URL(string: config.tractRemoteShareConnectionUrl)!
                
        super.init()
    }
    
    deinit {
        socket?.disconnect()
    }
    
    func connect() {
        
        guard !isConnected else {
            return
        }
        
        socket = WebSocket(request: URLRequest(url: remoteUrl))
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
        
        case .disconnected(let reason, let code):
            isConnected = false
            didDisconnectSignal.accept()
        
        case .text(let string):
            
            didReceiveTextSignal.accept(value: string)
            
            let data: Data? = string.data(using: .utf8)
            let jsonObject: Any? = JsonServices().getJsonObject(data: data)
            if let jsonObject = jsonObject as? [String: Any] {
                didReceiveJsonSignal.accept(value: jsonObject)
            }
        
        case .binary( _):
            break
        
        case .ping(_):
            break
        
        case .pong(_):
            break
        
        case .viabilityChanged(let changed):
            break
        
        case .reconnectSuggested(let suggested):
            break
        
        case .cancelled:
            isConnected = false
        
        case .error(let error):
            isConnected = false
            break
        }
    }
}
