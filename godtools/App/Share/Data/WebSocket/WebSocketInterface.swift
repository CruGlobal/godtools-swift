//
//  WebSocketInterface.swift
//  godtools
//
//  Created by Levi Eggert on 8/18/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol WebSocketInterface: Actor {
    
    var connectionState: WebSocketConnectionState { get }
    var isConnected: Bool { get }
    var isConnecting: Bool { get }
    
    func getConnectionStateStream() -> AsyncStream<WebSocketConnectionState>
    func getReceiveTextStream() async -> AsyncThrowingStream<String, any Error>?
    func connect(url: URL) async
    func disconnect() async
    func write(string: String)
}
