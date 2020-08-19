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
    private var isObservingTextSignal: Bool = false
    
    let didSubscribeToChannelSignal: SignalValue<String> = SignalValue()
    
    required init(webSocket: WebSocketType, loggingEnabled: Bool) {
        
        self.webSocket = webSocket
        self.loggingEnabled = loggingEnabled
        
        super.init()
    }
    
    deinit {
        webSocket.didConnectSignal.removeObserver(self)
        removeTextSignalObserver()
        unsubscribe()
        webSocket.disconnect()
    }
    
    var isSubscribedToChannel: Bool {
        return subscribedToChannel != nil
    }
    
    func subscribe(url: URL, channelId: String) {
        
        removeTextSignalObserver()
        
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
        
        removeTextSignalObserver()
        channelToSubscribeTo = nil
        isSubscribingToChannel = nil
        subscribedToChannel = nil
    }
    
    private func addTextSignalObserver() {
        if !isObservingTextSignal {
            isObservingTextSignal = true
            webSocket.didReceiveTextSignal.addObserver(self) { [weak self] (text: String) in
                self?.handleDidReceiveText(text: text)
            }
        }
    }
    
    private func removeTextSignalObserver() {
        if isObservingTextSignal {
            isObservingTextSignal = false
            webSocket.didReceiveTextSignal.removeObserver(self)
        }
    }
    
    private func handleDidSubscribeToChannel(channelId: String) {
        
        removeTextSignalObserver()
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
        
        addTextSignalObserver()
        
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
    
    private func handleDidReceiveText(text: String) {
        
        if loggingEnabled {
            print("\n ActionCableChannelSubscriber: handleDidReceiveText() \(text)")
        }
                
        guard let data = text.data(using: .utf8) else {
            return
        }
        
        let event: ActionCableEventType?
        
        do {
            event = try JSONDecoder().decode(ActionCableEventType.self, from: data)
        }
        catch {
            event = nil
        }
        
        if event?.type == "welcome" {

        }
        else if event?.type == "confirm_subscription" {
            if let channelToSubscribeTo = channelToSubscribeTo, let isSubscribingToChannel = isSubscribingToChannel {
                if channelToSubscribeTo == isSubscribingToChannel {
                    handleDidSubscribeToChannel(channelId: channelToSubscribeTo)
                }
            }
        }
    }
}
