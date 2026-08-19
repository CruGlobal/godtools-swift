//
//  KeepWebSocketAlive.swift
//  godtools
//
//  Created by Levi Eggert on 8/14/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

actor KeepWebSocketAlive {
    
    private static let pingIntervalSeconds: TimeInterval = 10
    
    private var keepAliveTask: Task<Void, Never>?
    
    func start(webSocketTask: URLSessionWebSocketTask) {
        
        stop()
        
        sendPing(webSocketTask: webSocketTask)
                
        keepAliveTask = Task { [weak self] in

            while !Task.isCancelled {

                try? await Task.sleep(for: .seconds(Self.pingIntervalSeconds))
                
                guard !Task.isCancelled, let self = self else {
                    return
                }
                
                await self.sendPing(webSocketTask: webSocketTask)
            }
        }
    }
    
    func stop() {
              
        keepAliveTask?.cancel()
        keepAliveTask = nil
    }
    
    private func sendPing(webSocketTask: URLSessionWebSocketTask) {
        
        webSocketTask.sendPing { _ in }
    }
}
