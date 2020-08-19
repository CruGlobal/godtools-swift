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
            channelId: channelId,
            locale: locale,
            page: page,
            tool: tool
        )
        
        var encodedObject: [String: Any] = navigationEvent.encodedObject
        
        encodedObject.updateValue("message", forKey: "command")

        let navigationEventString: String
        
        do {
            let navigationData: Data = try JSONSerialization.data(withJSONObject: encodedObject, options: [])
            navigationEventString = NSString(data: navigationData, encoding: String.Encoding.utf8.rawValue) as String? ?? ""
        }
        catch {
            navigationEventString = ""
        }
        
        print("\n SEND NAVIGATION EVENT")
        
//        let identifierJson: [String: Any] = ["channel": "SubscribeChannel", "channelId": channelId]
//        let messageJson: [String: Any] = [
//            "data": [
//                "attributes": ["page": navigationEvent.page, "card": navigationEvent.card, "locale": navigationEvent.locale, "tool": navigationEvent.tool],
//                "id": UUID().uuidString,
//                "type": "navigation-event"
//            ]
//        ]
//
//        let json: Any = ["identifier": identifierJson, "message": messageJson, "command": "message"]
//        let jsonString: String
//
//        do {
//            let data: Data = try JSONSerialization.data(withJSONObject: json, options: [])
//            jsonString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? ?? ""
//        }
//        catch let error {
//            jsonString = ""
//        }
        
        print("  navigationEventString: \(navigationEventString)")
        
        /*
        let jsonString: String
        
        do {
            let data: Data = try JSONEncoder().encode(json)
            jsonString = String(data: data, encoding: .utf8) ?? ""
        }
        catch let error {
            jsonString = ""
        }*/
        
        /*
        let stringData = "{ \"page\": \"\(navigationEvent.page ?? 0)\" }"
        let stringChannel = "{ \"channel\": \"SubscribeChannel\",\"channelId\": \"\(channelId)\" }"
        let message = ["command" : "message", "identifier": stringChannel, "message": navigationEventString]
        
        let messageString: String
        
        do {
            let data: Data = try JSONEncoder().encode(message)
            messageString = String(data: data, encoding: .utf8) ?? ""
        }
        catch let error {
            messageString = ""
        }*/
        
        webSocket.write(string: navigationEventString)
        
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
