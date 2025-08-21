//
//  MockWebSocket.swift
//  godtools
//
//  Created by Levi Eggert on 8/21/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class MockWebSocket: WebSocketInterface {
    
    private let didConnectSubject: PassthroughSubject<Void, Never> = PassthroughSubject()
    private let didReceiveTextSubject: PassthroughSubject<String, Never> = PassthroughSubject()
    
    private(set) var connectionState: WebSocketConnectionState = .disconnected
    
    let url: URL
    
    required init(url: URL) {
        self.url = url
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
        
        connectionState = .connected
        
        didConnectSubject.send(Void())
    }
    
    func disconnect() {
        
        connectionState = .disconnected
    }
    
    func write(string: String) {
        
        didReceiveTextSubject.send(string)
    }
}
