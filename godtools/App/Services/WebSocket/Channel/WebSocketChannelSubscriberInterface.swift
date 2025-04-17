//
//  WebSocketChannelSubscriberInterface.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

protocol WebSocketChannelSubscriberInterface {
    
    var didSubscribePublisher: AnyPublisher<WebSocketChannel, Never> { get }
    var isSubscribedToChannel: Bool { get }
    
    init(webSocket: WebSocketInterface, loggingEnabled: Bool)
    
    func subscribe(channel: WebSocketChannel)
    func unsubscribe()
}
