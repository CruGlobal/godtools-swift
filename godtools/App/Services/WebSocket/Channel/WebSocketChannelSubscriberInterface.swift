//
//  WebSocketChannelSubscriberInterface.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol WebSocketChannelSubscriberInterface {
    
    init(webSocket: WebSocketInterface, loggingEnabled: Bool)
    
    var didSubscribeToChannelSignal: SignalValue<String> { get }
    var isSubscribedToChannel: Bool { get }
    
    func subscribe(url: URL, channelId: String)
    func unsubscribe()
}
