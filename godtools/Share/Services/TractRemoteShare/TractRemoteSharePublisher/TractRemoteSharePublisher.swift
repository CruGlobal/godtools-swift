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
    
    func sendNavigationEvent(card: Int?, locale: String?, page: Int?, tool: String?) {
        
        guard let channelId = webSocketChannelPublisher.subscriberChannelId else {
            return
        }
        
        let navigationEvent = TractRemoteShareNavigationEvent(
            card: card,
            channel: "PublishChannel",
            channelId: channelId,
            locale: locale,
            page: page,
            tool: tool
        )
        
        let jsonServices: JsonServices = JsonServices()
        
        let identifier: [String: Any] = ["channel": "PublishChannel", "channelId": channelId]
        let stringIdentifier: String = jsonServices.getJsonString(json: identifier)
        
        let data: [String: Any] = [
            "data": [
                "id": UUID().uuidString,
                "type": "navigation-event",
                "attributes": ["card": card ?? -1, "locale": locale ?? "", "page": page ?? -1, "tool": tool ?? ""]
            ]
        ]
        let stringData: String = jsonServices.getJsonString(json: data)
            
        let message: [String: Any] = [
            "identifier": stringIdentifier,
            "data": stringData,
            "command": "message"
        ]
        let stringMessage: String = jsonServices.getJsonString(json: message)
        
                
        print("\n SEND NAVIGATION EVENT")
        print("  webSocketIsConnected: \(webSocketIsConnected)")
        print("  stringMessage: \(stringMessage)")
        
        webSocket.write(string: stringMessage)
        
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
    
    // MARK: - Log
    
    private func log(method: String, label: String?, labelValue: String?) {
        
        if loggingEnabled {
            print("\n TractRemoteSharePublisher \(method)")
            if let label = label, let labelValue = labelValue {
               print("  \(label): \(labelValue)")
            }
        }
    }
}
