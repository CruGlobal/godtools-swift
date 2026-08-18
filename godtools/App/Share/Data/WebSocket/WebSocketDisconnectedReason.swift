//
//  WebSocketDisconnectedReason.swift
//  godtools
//
//  Created by Levi Eggert on 8/18/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

enum WebSocketDisconnectedReason: Sendable {
    
    case clientDisconnected
    case didClose(reason: String?)
    case taskFinishedTransfer(failure: String?)
}
