//
//  TractRemoteSharePublisher.swift
//  godtools
//
//  Created by Levi Eggert on 8/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

class TractRemoteSharePublisher: NSObject {
        
    private static let timeoutIntervalSeconds: TimeInterval = 10
    
    private let webSocket: WebSocketInterface
    private let webSocketChannelPublisher: WebSocketChannelPublisherInterface
    private let didCreateChannelSubject: PassthroughSubject<WebSocketChannel, Never> = PassthroughSubject()
    private let didFailToCreateChannelSubject: PassthroughSubject<TractRemoteSharePublisherError, Never> = PassthroughSubject()
    private let loggingEnabled: Bool
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var timeoutTimer: Timer?
    
    private(set) var tractRemoteShareChannel: WebSocketChannel?
        
    init(config: AppConfig, webSocket: WebSocketInterface, webSocketChannelPublisher: WebSocketChannelPublisherInterface, loggingEnabled: Bool) {
        
        self.webSocket = webSocket
        self.webSocketChannelPublisher = webSocketChannelPublisher
        self.loggingEnabled = loggingEnabled
        
        super.init()
        
        webSocketChannelPublisher
            .didCreateChannelPublisher
            .sink { [weak self] (channel: WebSocketChannel) in
                
                self?.stopTimeoutTimer()
                                
                self?.tractRemoteShareChannel = channel
                
                self?.didCreateChannelSubject.send(channel)
            }
            .store(in: &cancellables)
    }
    
    deinit {
        endPublishingSession(disconnectSocket: true)
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
    
    var didCreateChannelPublisher: AnyPublisher<WebSocketChannel, Never> {
        return didCreateChannelSubject
            .eraseToAnyPublisher()
    }
    
    var didFailToCreateChannelPublisher: AnyPublisher<TractRemoteSharePublisherError, Never> {
        return didFailToCreateChannelSubject
            .eraseToAnyPublisher()
    }
    
    var webSocketIsConnected: Bool {
        return webSocket.connectionState == .connected
    }
    
    var isSubscriberChannelCreatedForPublish: Bool {
        return webSocketChannelPublisher.isSubscriberChannelCreatedForPublish
    }
    
    var subscriberChannelId: String? {
        return webSocketChannelPublisher.subscriberChannel?.id
    }
    
    func createNewSubscriberChannelIdForPublish() {
        
        endPublishingSession(disconnectSocket: false)
                
        let channel = WebSocketChannel.createUniqueChannel()
                
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: Self.timeoutIntervalSeconds, repeats: false) { [weak self] _ in
            
            self?.stopTimeoutTimer()
            
            self?.didFailToCreateChannelSubject.send(.timedOut)
        }
        
        webSocketChannelPublisher.createChannel(channel: channel)
    }
    
    func endPublishingSession(disconnectSocket: Bool) {
        
        stopTimeoutTimer()
        tractRemoteShareChannel = nil
        
        if disconnectSocket {
            webSocket.disconnect()
        }
    }
    
    func sendNavigationEvent(event: TractRemoteSharePublisherNavigationEvent) {
                
        let navigationAttributes = TractRemoteShareNavigationEvent.Attributes(card: event.card, locale: event.locale, page: event.page, tool: event.tool)
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
                                                
        webSocketChannelPublisher.sendMessage(data: stringData)
        
        if loggingEnabled {
            print("\n TractRemoteSharePublisher: sendNavigationEvent()")
            print("  card: \(String(describing: event.card))")
            print("  locale: \(String(describing: event.locale))")
            print("  page: \(String(describing: event.page))")
            print("  tool: \(String(describing: event.tool))")
        }
    }
}
