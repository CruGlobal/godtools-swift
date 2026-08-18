//
//  TractRemoteSharePublisher.swift
//  godtools
//
//  Created by Levi Eggert on 8/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

actor TractRemoteSharePublisher {
            
    private let webSocket: URLSessionWebSocket
    private let connectionUrl: String
    private let channelPublisher: ACChannelPublisher
    private let loggingEnabled: Bool
        
    private(set) var tractRemoteShareChannel: WebSocketChannel?
        
    init(
        webSocket: URLSessionWebSocket,
        connectionUrl: String,
        channelPublisher: ACChannelPublisher,
        loggingEnabled: Bool
    ) {
        
        self.webSocket = webSocket
        self.connectionUrl = connectionUrl
        self.channelPublisher = channelPublisher
        self.loggingEnabled = loggingEnabled
           
        // TODO: Fix. ~Levi
        /*
         channelPublisher
            .didCreateChannelPublisher
            .sink { [weak self] (channel: WebSocketChannel) in
                
                self?.stopTimeoutTimer()
                                
                self?.tractRemoteShareChannel = channel
                
                self?.didCreateChannelSubject.send(channel)
            }
            .store(in: &cancellables)*/
    }
    
    deinit {
        // TODO: Fix. ~Levi
        //endPublishingSession(disconnectSocket: true)
    }
    
    private func log(method: String, label: String?, labelValue: String?) {
        
        if loggingEnabled {
            print("\n TractRemoteSharePublisher \(method)")
            if let label = label, let labelValue = labelValue {
                print("  \(label): \(labelValue)")
            }
        }
    }
    
    var webSocketIsConnected: Bool {
        get async {
            return await webSocket.isConnected
        }
    }
    
    var isSubscriberChannelCreatedForPublish: Bool {
        get async {
            return await channelPublisher.isSubscriberChannelCreatedForPublish
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
        
        tractRemoteShareChannel = nil
        
        if disconnectSocket {
            
            await webSocket.disconnect()
        }
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
