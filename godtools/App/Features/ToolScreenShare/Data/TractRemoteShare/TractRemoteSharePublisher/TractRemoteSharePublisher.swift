//
//  TractRemoteSharePublisher.swift
//  godtools
//
//  Created by Levi Eggert on 8/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

actor TractRemoteSharePublisher {
        
    private static let timeoutIntervalSeconds: TimeInterval = 10
    
    private let webSocket: URLSessionWebSocket
    private let webSocketChannelPublisher: ActionCableChannelPublisher
    private let loggingEnabled: Bool
    
    private var timeoutTimer: Timer?
    
    private(set) var tractRemoteShareChannel: WebSocketChannel?
        
    init(
        webSocket: URLSessionWebSocket,
        webSocketChannelPublisher: ActionCableChannelPublisher,
        loggingEnabled: Bool
    ) {
        
        self.webSocket = webSocket
        self.webSocketChannelPublisher = webSocketChannelPublisher
        self.loggingEnabled = loggingEnabled
           
        // TODO: Fix. ~Levi
        /*
        webSocketChannelPublisher
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
    
    private func stopTimeoutTimer() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
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
        
        return false
        // TODO: Fix. ~Levi
        //return webSocket.connectionState == .connected
    }
    
    var isSubscriberChannelCreatedForPublish: Bool {
        get async {
            return await webSocketChannelPublisher.isSubscriberChannelCreatedForPublish
        }
    }
    
    var subscriberChannelId: String? {
        get async {
            return await webSocketChannelPublisher.subscriberChannel?.id
        }
    }
    
    func createChannelForPublish() async {
        
        endPublishingSession(disconnectSocket: false)
                
        let channel = WebSocketChannel.createUniqueChannel()
                
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: Self.timeoutIntervalSeconds, repeats: false) { [weak self] _ in
            
            self?.stopTimeoutTimer()
            
            // TODO: Fix. ~Levi
            //self?.didFailToCreateChannelSubject.send(.timedOut)
        }
        
        await webSocketChannelPublisher.createChannel(channel: channel)
    }
    
    func endPublishingSession(disconnectSocket: Bool) {
        
        stopTimeoutTimer()
        tractRemoteShareChannel = nil
        
        if disconnectSocket {
           
            // TODO: Fix. ~Levi
            //webSocket.disconnect()
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
                                                
        await webSocketChannelPublisher.sendMessage(data: stringData)
        
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
