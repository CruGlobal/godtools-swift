//
//  TractRemoteSharePublisher.swift
//  godtools
//
//  Created by Levi Eggert on 8/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

actor TractRemoteSharePublisher {
            
    private let connectionUrl: String
    private let channelPublisher: ACChannelPublisher
    private let loggingEnabled: Bool
                
    init(
        connectionUrl: String,
        channelPublisher: ACChannelPublisher,
        loggingEnabled: Bool
    ) {
        
        self.connectionUrl = connectionUrl
        self.channelPublisher = channelPublisher
        self.loggingEnabled = loggingEnabled
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func log(method: String, label: String?, labelValue: String?) {
        
        if loggingEnabled {
            print("\n TractRemoteSharePublisher \(method)")
            if let label = label, let labelValue = labelValue {
                print("  \(label): \(labelValue)")
            }
        }
    }
    
    var subscriberChannel: WebSocketChannel? {
        get async {
            return await channelPublisher.subscriberChannel
        }
    }
    
    var connectionState: WebSocketConnectionState {
        get async {
            return await channelPublisher.connectionState
        }
    }
    
    func getCreatedChannelStream() async -> AsyncStream<WebSocketChannel> {
        return await channelPublisher.getCreatedChannelStream()
    }
    
    var isSubscriberChannelCreated: Bool {
        get async {
            return await channelPublisher.isSubscriberChannelCreated
        }
    }
    
    var subscriberChannelId: String? {
        get async {
            return await channelPublisher.subscriberChannel?.id
        }
    }
    
    func createChannelForPublish() async throws {
                
        guard let url = URL(string: connectionUrl) else {
            
            throw NSError.errorWithDomain(
                domain: "TractRemoteSharePublisher",
                code: -1,
                description: "Failed to create connection url with string: \(connectionUrl)"
            )
        }
        
        await endPublishingSession(disconnectSocket: false)
                
        let channel = WebSocketChannel.createUniqueChannel()
        
        try await channelPublisher.createChannel(url: url, channel: channel)
    }
    
    func endPublishingSession(disconnectSocket: Bool) async {
                
        await channelPublisher.closeChannel(disconnectSocket: disconnectSocket)
    }
    
    func sendNavigationEvent(event: TractRemoteSharePublisherNavigationEvent) async {
                
        let navigationAttributes = TractRemoteShareNavigationEvent.Attributes(
            card: event.card,
            locale: event.locale,
            page: event.page,
            parallelLocale: event.parallelLocale,
            primaryLocale: event.primaryLocale,
            tool: event.tool
        )
       
        let navigationData = TractRemoteShareNavigationEvent.Data(attributes: navigationAttributes)
        let navigationMessage = TractRemoteShareNavigationEvent.Message(data: navigationData)
        
        let stringData: String
            
        do {
            let navigationData: Data = try JSONEncoder().encode(navigationMessage)
            stringData = String(data: navigationData, encoding: .utf8) ?? ""
        }
        catch {
            stringData = ""
        }
                                                
        await channelPublisher.sendMessage(data: stringData)
        
        if loggingEnabled {
            print("\n TractRemoteSharePublisher: sendNavigationEvent()")
            print("  card: \(String(describing: event.card))")
            print("  locale: \(String(describing: event.locale))")
            print("  page: \(String(describing: event.page))")
            print("  parallelLocale: \(String(describing: event.parallelLocale))")
            print("  primaryLocale: \(String(describing: event.primaryLocale))")
            print("  tool: \(String(describing: event.tool))")
        }
    }
}
