//
//  ActionCableChannelSubscriber.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ActionCableChannelSubscriber: NSObject, WebSocketChannelSubscriberType {
    
    private let webSocket: WebSocketType
    private let loggingEnabled: Bool
    
    private var channelToSubscribeTo: String?
    private var isSubscribingToChannel: String?
    private var subscribedToChannel: String?
    private var isObservingJsonSignal: Bool = false
    
    let didSubscribeToChannelSignal: SignalValue<String> = SignalValue()
    
    required init(webSocket: WebSocketType, loggingEnabled: Bool) {
        
        self.webSocket = webSocket
        self.loggingEnabled = loggingEnabled
        
        super.init()
    }
    
    deinit {
        webSocket.didConnectSignal.removeObserver(self)
        removeJsonSignalObserver()
        unsubscribe()
        webSocket.disconnect()
    }
    
    var isSubscribedToChannel: Bool {
        return subscribedToChannel != nil
    }
    
    func subscribe(url: URL, channelId: String) {
        
        removeJsonSignalObserver()
        
        channelToSubscribeTo = channelId
        
        if !webSocket.isConnected {
            
            webSocket.didConnectSignal.addObserver(self) { [weak self] in
                
                guard let channelSubscriber = self else {
                    return
                }
                channelSubscriber.webSocket.didConnectSignal.removeObserver(channelSubscriber)
                channelSubscriber.handleDidConnectToWebsocket()
            }
            
            webSocket.connect(url: url)
        }
        else {
            
            handleDidConnectToWebsocket()
        }
    }
    
    func unsubscribe() {
        
        removeJsonSignalObserver()
        channelToSubscribeTo = nil
        isSubscribingToChannel = nil
        subscribedToChannel = nil
    }
    
    private func addJsonSignalObserver() {
        if !isObservingJsonSignal {
            isObservingJsonSignal = true
            webSocket.didReceiveJsonSignal.addObserver(self) { [weak self] (json: [String: Any]) in
                self?.handleDidReceiveJson(json: json)
            }
        }
    }
    
    private func removeJsonSignalObserver() {
        if isObservingJsonSignal {
            isObservingJsonSignal = false
            webSocket.didReceiveJsonSignal.removeObserver(self)
        }
    }
    
    private func handleDidSubscribeToChannel(channelId: String) {
        
        removeJsonSignalObserver()
        channelToSubscribeTo = nil
        isSubscribingToChannel = nil
        subscribedToChannel = channelId
        didSubscribeToChannelSignal.accept(value: channelId)
    }
    
    private func handleDidConnectToWebsocket() {
               
        if loggingEnabled {
            print("\n ActionCableChannelSubscriber: handleDidConnectToWebsocket()")
        }
        
        guard let channelId = channelToSubscribeTo else {
            return
        }
        
        addJsonSignalObserver()
        
        isSubscribingToChannel = channelId
        
        let strChannel = "{ \"channel\": \"SubscribeChannel\",\"channelId\": \"\(channelId)\" }"
        let message = ["command" : "subscribe","identifier": strChannel]

        do {
            
            let data = try JSONSerialization.data(withJSONObject: message)
            if let dataString = String(data: data, encoding: .utf8){
                webSocket.write(string: dataString)
            }
            
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
    }
    
    private func handleDidReceiveJson(json: [String: Any]) {
        
        if loggingEnabled {
            print("\n ActionCableChannelSubscriber: handleDidReceiveJson() \(json)")
        }
        
        if let type = json["type"] as? String {
            
            if type == "welcome" { // sent when subscribing to a channel
                
            }
            else if type == "confirm_subscription" { // sent when subscribing to a channel
                if let channelToSubscribeTo = channelToSubscribeTo, let isSubscribingToChannel = isSubscribingToChannel {
                    if channelToSubscribeTo == isSubscribingToChannel {
                        handleDidSubscribeToChannel(channelId: channelToSubscribeTo)
                    }
                }
            }
        }
    }
}
