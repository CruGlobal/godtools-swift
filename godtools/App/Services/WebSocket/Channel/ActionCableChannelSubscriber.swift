//
//  ActionCableChannelSubscriber.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

class ActionCableChannelSubscriber: NSObject, WebSocketChannelSubscriberInterface {
    
    private let webSocket: WebSocketInterface
    private let loggingEnabled: Bool
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var channelToSubscribeTo: String?
    private var isSubscribingToChannel: String?
    private var subscribedToChannel: String?
    private var isObservingTextSignal: Bool = false
    
    let didSubscribeToChannelSignal: SignalValue<String> = SignalValue()
    
    required init(webSocket: WebSocketInterface, loggingEnabled: Bool) {
        
        self.webSocket = webSocket
        self.loggingEnabled = loggingEnabled
        
        super.init()
        
        webSocket
            .didReceiveTextPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (text: String) in
                self?.handleDidReceiveText(text: text)
            })
            .store(in: &cancellables)
    }
    
    deinit {
        unsubscribe()
        webSocket.disconnect()
    }
    
    var isSubscribedToChannel: Bool {
        return subscribedToChannel != nil
    }
    
    func subscribe(url: URL, channelId: String) {
                
        channelToSubscribeTo = channelId
        
        if webSocket.connectionState != .connected && webSocket.connectionState != .connecting {
            
            webSocket.connectPublisher(url: url)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    
                    switch completion {
                    case .finished:
                        self?.handleDidConnectToWebsocket()
                    case .failure(let error):
                        break
                    }
                    
                } receiveValue: { _ in
                    
                }
                .store(in: &cancellables)
        }
        else if webSocket.connectionState == .connected {
            
            handleDidConnectToWebsocket()
        }
    }
    
    func unsubscribe() {
        
        channelToSubscribeTo = nil
        isSubscribingToChannel = nil
        subscribedToChannel = nil
    }
    
    private func handleDidSubscribeToChannel(channelId: String) {
        
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
                
        isSubscribingToChannel = channelId
        
        let strChannel = "{ \"channel\": \"SubscribeChannel\",\"channelId\": \"\(channelId)\" }"
        let message = ["command": "subscribe", "identifier": strChannel]

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
