//
//  WebSocketChannelSubscriberType.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol WebSocketChannelSubscriberType {
    
    init(webSocket: WebSocketType, loggingEnabled: Bool)
    
    var didSubscribeToChannelSignal: SignalValue<String> { get }
    var isSubscribedToChannel: Bool { get }
    
    func subscribe(url: URL, channelId: String)
    func unsubscribe()
}
