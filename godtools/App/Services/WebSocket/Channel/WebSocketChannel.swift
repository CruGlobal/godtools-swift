//
//  WebSocketChannel.swift
//  godtools
//
//  Created by Levi Eggert on 4/3/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct WebSocketChannel {
    
    let id: String
    
    init?(id: String) {
        
        guard !id.isEmpty else {
            return nil
        }
        
        self.id = id
    }
    
    private init() {
        id = UUID().uuidString
    }
    
    static func createUniqueChannel() -> WebSocketChannel {
        return WebSocketChannel()
    }
}

extension WebSocketChannel: Equatable {
    
    static func == (this: WebSocketChannel, that: WebSocketChannel) -> Bool {
        return this.id == that.id
    }
}
