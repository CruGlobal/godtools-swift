//
//  ACChannelPublisherInterface.swift
//  godtools
//
//  Created by Levi Eggert on 8/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol ACChannelPublisherInterface: Actor {
    
    var publishChannel: WebSocketChannel? { get }
    var subscriberChannel: WebSocketChannel? { get }
    var isCreatingChannel: Bool { get }
    var subscriberChannelCreated: Bool { get }
    var connectionState: WebSocketConnectionState { get async }
    
    func getConnectionStateStream() async -> AsyncStream<WebSocketConnectionState>
    func getCreatedChannelStream() async -> AsyncThrowingStream<WebSocketChannel, Error>
    func createChannel(url: URL, channel: WebSocketChannel) async throws(ACCreateChannelError)
    func closeChannel(disconnectSocket: Bool) async
    func sendMessage(data: String) async
}
