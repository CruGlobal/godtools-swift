//
//  TractRemoteShareSubscriber.swift
//  godtools
//
//  Created by Levi Eggert on 7/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

class TractRemoteShareSubscriber: NSObject {
            
    private static let timeoutIntervalSeconds: TimeInterval = 10
    
    private let webSocket: WebSocketInterface
    private let webSocketChannelSubscriber: WebSocketChannelSubscriberInterface
    private let didSubscribeSubject: PassthroughSubject<WebSocketChannel, Never> = PassthroughSubject()
    private let didFailToSubscribeSubject: PassthroughSubject<TractRemoteShareSubscriberError, Never> = PassthroughSubject()
    private let navigationEventSubject: PassthroughSubject<TractRemoteShareNavigationEvent, Never> = PassthroughSubject()
    private let loggingEnabled: Bool
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var timeoutTimer: Timer?
    private var isSubscribingToChannel: WebSocketChannel?
    
    required init(webSocket: WebSocketInterface, webSocketChannelSubscriber: WebSocketChannelSubscriberInterface, loggingEnabled: Bool) {
        
        self.webSocket = webSocket
        self.webSocketChannelSubscriber = webSocketChannelSubscriber
        self.loggingEnabled = loggingEnabled
        
        super.init()
        
        webSocket
            .didReceiveTextPublisher
            .sink(receiveValue: { [weak self] (text: String) in
                self?.handleDidReceiveText(text: text)
            })
            .store(in: &cancellables)
        
        webSocketChannelSubscriber
            .didSubscribePublisher
            .sink { [weak self] (channel: WebSocketChannel) in
                
                self?.stopTimeoutTimer()
                
                self?.didSubscribeSubject.send(channel)
            }
            .store(in: &cancellables)
    }
    
    deinit {
        unsubscribe(disconnectSocket: true)
    }
    
    private func stopTimeoutTimer() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }
        
    private func log(method: String, label: String?, labelValue: String?) {
        
        if loggingEnabled {
            print("\n TractRemoteShareSubscriber \(method)")
            if let label = label, let labelValue = labelValue {
                print("  \(label): \(labelValue)")
            }
        }
    }
    
    var didSubscribePublisher: AnyPublisher<WebSocketChannel, Never> {
        return didSubscribeSubject
            .eraseToAnyPublisher()
    }
    
    var didFailToSubscribePublisher: AnyPublisher<TractRemoteShareSubscriberError, Never> {
        return didFailToSubscribeSubject
            .eraseToAnyPublisher()
    }
    
    var navigationEventPublisher: AnyPublisher<TractRemoteShareNavigationEvent, Never> {
        return navigationEventSubject
            .eraseToAnyPublisher()
    }
    
    var webSocketIsConnected: Bool {
        return webSocket.connectionState == .connected
    }
    
    var isSubscribedToChannel: Bool {
        return webSocketChannelSubscriber.isSubscribedToChannel
    }
    
    func subscribe(channel: WebSocketChannel) {
            
        log(method: "subscribe()", label: "channelId", labelValue: channel.id)
                
        unsubscribe(disconnectSocket: false)
        
        isSubscribingToChannel = channel
                        
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: Self.timeoutIntervalSeconds, repeats: false) { [weak self] _ in
            
            self?.stopTimeoutTimer()
            
            self?.didFailToSubscribeSubject.send(.timedOut)
        }
        
        webSocketChannelSubscriber.subscribe(channel: channel)
    }
    
    func unsubscribe(disconnectSocket: Bool) {
        
        stopTimeoutTimer()
        
        isSubscribingToChannel = nil
                
        webSocketChannelSubscriber.unsubscribe()
        
        if disconnectSocket {
            webSocket.disconnect()
        }
    }
}

// MARK: - Events

extension TractRemoteShareSubscriber {
    
    private func handleDidReceiveText(text: String) {
            
        log(method: "handleDidReceiveText()", label: "text", labelValue: text)
        
        let data: Data? = text.data(using: .utf8)
        
        let object: TractRemoteShareNavigationEvent? = JsonServices().decodeObject(data: data)
                
        if let object = object, object.message?.data?.type == "navigation-event" {
            
            navigationEventSubject.send(object)
        }
    }
}
