//
//  TractRemoteShareSubscriber.swift
//  godtools
//
//  Created by Levi Eggert on 7/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import ActionCableClient

class TractRemoteShareSubscriber {
        
    private let client: ActionCableClient
    private let jsonServices: JsonServices = JsonServices()
    
    private var currentChannel: Channel?
    
    let navigationEventSignal: SignalValue<TractRemoteShareNavigationEvent> = SignalValue()
    
    required init(config: ConfigType) {
        
        let remoteUrl: URL? = URL(string: config.mobileContentApiBaseUrl + "/" + "cable")
        
        client = ActionCableClient(url: remoteUrl!)
    }
    
    deinit {
        
        unsubscribeCurrentChannel()
        disconnectClient()
    }
    
    private func connectClient(complete: @escaping (() -> Void)) {
        
        guard !client.isConnected else {
            complete()
            return
        }
        
        client.onConnected = {
            print("\nTractRemoteShareSubscriber: connected")
            complete()
        }
        
        client.connect()
    }
    
    private func disconnectClient() {
        
        client.onDisconnected = {(error: Error?) in
            
            print("\nTractRemoteShareSubscriber disconnectClient() error:\(String(describing: error))")
        }
        
        client.disconnect()
    }
    
    private func unsubscribeCurrentChannel() {
        
        currentChannel?.unsubscribe()
        currentChannel = nil
    }
    
    func unsubscribeChannel() {
        unsubscribeCurrentChannel()
        disconnectClient()
    }
    
    func subscribeToChannel(liveShareStream: String) {
                
        connectClient { [weak self] in
            
            self?.internalSubscribeToChannel(liveShareStream: liveShareStream)
        }
    }
    
    private func internalSubscribeToChannel(liveShareStream: String) {
        
        print("\nTractRemoteShareSubscriber: internalSubscribeToChannel() \(liveShareStream)")
        
        unsubscribeCurrentChannel()
        
        let channelId: [String: String] = ["channelId": liveShareStream]
        
        let channel: Channel = client.create(
            "SubscribeChannel",
            identifier: channelId,
            autoSubscribe: false,
            bufferActions: true
        )
        
        // Receive a message from the server. Typically a Dictionary.
        channel.onReceive = { [weak self] (json : Any?, error : Error?) in
            self?.handleChannelReceivedData(json: json, error: error)
        }

        // A channel has successfully been subscribed to.
        channel.onSubscribed = {
            print("\nTractRemoteShareSubscriber Channel Subscribed!")
        }
        
        // A channel was unsubscribed, either manually or from a client disconnect.
        channel.onUnsubscribed = {
            print("\nTractRemoteShareSubscriber Channel Unsubscribed")
        }

        // The attempt at subscribing to a channel was rejected by the server.
        channel.onRejected = {
            print("\nTractRemoteShareSubscriber Channel Rejected")
        }
        
        channel.subscribe()
        
        currentChannel = channel
    }
    
    private func handleChannelReceivedData(json: Any?, error : Error?) {
        
        guard error == nil else {
            return
        }
        
        guard let jsonData = (json as? [String: Any])?["data"] as? [String: Any] else {
            return
        }
        
        guard let eventType = jsonData["type"] as? String, let attributes = jsonData["attributes"] as? [String: Any] else {
            return
        }
        
        let data: Data? = jsonServices.getJsonData(json: attributes)
                
        print("\nTractRemoteShareSubscriber: handleChannelReceivedData()  EVENT TYPE: \(eventType)")
        
        if eventType == "navigation-event" {
            
            let navigationEvent: TractRemoteShareNavigationEvent? = jsonServices.decodeObject(data: data)
            
            if let event = navigationEvent {
                navigationEventSignal.accept(value: event)
            }
            
            print("  navigationEvent.page: \(String(describing: navigationEvent?.page))")
            print("  navigationEvent.card: \(String(describing: navigationEvent?.card))")
            print("  navigationEvent.locale: \(String(describing: navigationEvent?.locale))")
            print("  navigationEvent.tool: \(String(describing: navigationEvent?.tool))")
        }
    }
}
