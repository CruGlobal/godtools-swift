//
//  WebSocketConnectionState.swift
//  godtools
//
//  Created by Levi Eggert on 4/3/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

enum WebSocketConnectionState: Sendable {
    
    case connected
    case connecting
    case disconnected(reason: WebSocketDisconnectedReason)
    case noState
    
    var isConnected: Bool {
        switch self {
        case .connected:
            return true
        default:
            return false
        }
    }
    
    var isConnecting: Bool {
        switch self {
        case .connecting:
            return true
        default:
            return false
        }
    }
}
