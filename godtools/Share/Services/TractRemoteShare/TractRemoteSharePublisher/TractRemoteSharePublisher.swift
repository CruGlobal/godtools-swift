//
//  TractRemoteSharePublisher.swift
//  godtools
//
//  Created by Levi Eggert on 8/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TractRemoteSharePublisher: NSObject {
    
    private let remoteUrl: URL
    private let webSocket: WebSocketType
    private let webSocketChannelPublisher: WebSocketChannelPublisherType
    private let loggingEnabled: Bool
    
    required init(config: ConfigType, webSocket: WebSocketType, webSocketChannelPublisher: WebSocketChannelPublisherType, loggingEnabled: Bool) {
        
        self.remoteUrl = URL(string: config.tractRemoteShareConnectionUrl)!
        self.webSocket = webSocket
        self.webSocketChannelPublisher = webSocketChannelPublisher
        self.loggingEnabled = loggingEnabled
        
        super.init()
    }
    
    deinit {

    }
    
    var webSocketIsConnected: Bool {
        return webSocket.isConnected
    }
    
    func createNewPublisher() {
        
        let channelId: String = UUID().uuidString
        
        webSocketChannelPublisher.createChannelForPublish(url: remoteUrl, channelId: channelId)
    }
}
