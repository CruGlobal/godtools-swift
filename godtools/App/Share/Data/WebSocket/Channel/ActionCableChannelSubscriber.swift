//
//  ActionCableChannelSubscriber.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

final class ActionCableChannelSubscriber: NSObject {
    
    private let webSocket: URLSessionWebSocket
    private let didSubscribeSubject: PassthroughSubject<WebSocketChannel, Never> = PassthroughSubject()
    private let loggingEnabled: Bool
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var channelToSubscribeTo: WebSocketChannel?
    private var isSubscribingToChannel: WebSocketChannel?
    private var subscribedToChannel: WebSocketChannel?
        
    init(webSocket: URLSessionWebSocket, loggingEnabled: Bool) {
        
        self.webSocket = webSocket
        self.loggingEnabled = loggingEnabled
        
        super.init()
        
        // TODO: Fix. ~Levi
        /*
        webSocket
            .didConnectPublisher
            .sink { [weak self] _ in
                self?.handleDidConnectToWebsocket()
            }
            .store(in: &cancellables)
        
        webSocket
            .didReceiveTextPublisher
            .sink(receiveValue: { [weak self] (text: String) in
                self?.handleDidReceiveText(text: text)
            })
            .store(in: &cancellables)*/
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        
        // TODO: Fix. ~Levi
        //unsubscribe()
        //webSocket.disconnect()
    }
    
    var didSubscribePublisher: AnyPublisher<WebSocketChannel, Never> {
        return didSubscribeSubject
            .eraseToAnyPublisher()
    }
    
    var isSubscribedToChannel: Bool {
        return subscribedToChannel != nil
    }

    func subscribe(channel: WebSocketChannel) {
        
        channelToSubscribeTo = channel
        
        // TODO: Fix. ~Levi
        
        /*
        if webSocket.connectionState != .connected && webSocket.connectionState != .connecting {
            
            webSocket.connect()
        }
        else if webSocket.connectionState == .connected {
            
            handleDidConnectToWebsocket()
        }*/
    }
    
    func unsubscribe() {
        
        channelToSubscribeTo = nil
        isSubscribingToChannel = nil
        subscribedToChannel = nil
    }
    
    private func handleDidSubscribeToChannel(channel: WebSocketChannel) {
        
        channelToSubscribeTo = nil
        isSubscribingToChannel = nil
        subscribedToChannel = channel
        didSubscribeSubject.send(channel)
    }
    
    private func handleDidConnectToWebsocket() {
              
        // TODO: Fix. ~Levi
        
        /*
        if loggingEnabled {
            print("\n ActionCableChannelSubscriber: handleDidConnectToWebsocket()")
        }
        
        guard let channel = channelToSubscribeTo else {
            return
        }
                
        isSubscribingToChannel = channel
        
        let strChannel = "{ \"channel\": \"SubscribeChannel\",\"channelId\": \"\(channel.id)\" }"
        let message = ["command": "subscribe", "identifier": strChannel]

        do {
            
            let data = try JSONSerialization.data(withJSONObject: message)
            if let dataString = String(data: data, encoding: .utf8){
                webSocket.write(string: dataString)
            }
            
        } catch let error {
            assertionFailure(error.localizedDescription)
        }*/
    }
    
    private func handleDidReceiveText(text: String) {
        
        if loggingEnabled {
            print("\n ActionCableChannelSubscriber: handleDidReceiveText() \(text)")
        }
                
        guard let data = text.data(using: .utf8) else {
            return
        }
        
        let event: ActionCableEventCodable?
        
        do {
            event = try JSONDecoder().decode(ActionCableEventCodable.self, from: data)
        }
        catch {
            event = nil
        }
        
        if event?.type == "welcome" {

        }
        else if event?.type == "confirm_subscription" {
            
            if let channelToSubscribeTo = channelToSubscribeTo,
               let isSubscribingToChannel = isSubscribingToChannel,
               channelToSubscribeTo == isSubscribingToChannel {
                
                handleDidSubscribeToChannel(channel: channelToSubscribeTo)
            }
        }
    }
}
