//
//  TractRemoteSharePublisher.swift
//  godtools
//
//  Created by Levi Eggert on 8/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TractRemoteSharePublisher: NSObject {
    
    typealias CreateNewPublisherCompletion = ((_ channel: TractRemoteShareChannel) -> Void)
    
    private let remoteUrl: URL
    private let webSocket: WebSocketType
    private let webSocketChannelPublisher: WebSocketChannelPublisherType
    private let loggingEnabled: Bool
    
    private var createNewPublisherBlock: CreateNewPublisherCompletion?
    private var isObservingSignals: Bool = false
    
    let didCreateNewSubscriberChannelIdForPublish: SignalValue<TractRemoteShareChannel> = SignalValue()
    
    required init(config: ConfigType, webSocket: WebSocketType, webSocketChannelPublisher: WebSocketChannelPublisherType, loggingEnabled: Bool) {
        
        self.remoteUrl = URL(string: config.tractRemoteShareConnectionUrl)!
        self.webSocket = webSocket
        self.webSocketChannelPublisher = webSocketChannelPublisher
        self.loggingEnabled = loggingEnabled
        
        super.init()
    }
    
    deinit {
        
        createNewPublisherBlock = nil
        removeObsevers()
    }
    
    var webSocketIsConnected: Bool {
        return webSocket.isConnected
    }
    
    var isSubscriberChannelIdCreatedForPublish: Bool {
        return webSocketChannelPublisher.isSubscriberChannelIdCreatedForPublish
    }
    
    func createNewSubscriberChannelIdForPublish(complete: @escaping CreateNewPublisherCompletion) {
        
        createNewPublisherBlock = complete
        
        addObservers()
        
        let channelId: String = UUID().uuidString
        
        webSocketChannelPublisher.createChannelForPublish(url: remoteUrl, channelId: channelId)
    }
    
    func endPublishingSession(disconnectSocket: Bool) {
        
        if disconnectSocket {
            webSocket.disconnect()
        }
    }
    
    func sendNavigationEvent(navigationEvent: TractRemoteShareNavigationEvent) {
        
        print("\n SEND NAVIGATION EVENT")
    }
    
    // MARK: - Observers
    
    private func addObservers() {
        
        if !isObservingSignals {
            
            isObservingSignals = true
            
            webSocketChannelPublisher.didCreateChannelForPublish.addObserver(self) { [weak self] (subscriberChannelId: String) in
                
                let channel = TractRemoteShareChannel(
                    subscriberChannelId: subscriberChannelId
                )
                
                self?.createNewPublisherBlock?(channel)
                
                self?.didCreateNewSubscriberChannelIdForPublish.accept(value: channel)
            }
        }
    }
    
    private func removeObsevers() {
        
        if isObservingSignals {
            
            isObservingSignals = false
            
            webSocketChannelPublisher.didCreateChannelForPublish.removeObserver(self)
        }
    }
}
