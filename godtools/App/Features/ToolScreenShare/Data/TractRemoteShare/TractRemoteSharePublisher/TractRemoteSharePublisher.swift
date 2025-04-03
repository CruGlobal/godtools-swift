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
    
    private let remoteUrl: URL
    private let webSocket: WebSocketInterface
    private let webSocketChannelPublisher: WebSocketChannelPublisherInterface
    private let didCreateChannelSubject: PassthroughSubject<WebSocketChannel, TractRemoteSharePublisherError> = PassthroughSubject()
    private let loggingEnabled: Bool
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var timeoutTimer: Timer?
    
    private(set) var tractRemoteShareChannel: WebSocketChannel?
        
    init(config: AppConfig, webSocket: WebSocketInterface, webSocketChannelPublisher: WebSocketChannelPublisherInterface, loggingEnabled: Bool) {
        
        // TODO: Shouldn't force unwrap url here. ~Levi
        self.remoteUrl = URL(string: config.getTractRemoteShareConnectionUrl())!
        self.webSocket = webSocket
        self.webSocketChannelPublisher = webSocketChannelPublisher
        self.loggingEnabled = loggingEnabled
        
        super.init()
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
    
    var webSocketIsConnected: Bool {
        return webSocket.connectionState == .connected
    }
    
    var isSubscriberChannelCreatedForPublish: Bool {
        return webSocketChannelPublisher.isSubscriberChannelCreatedForPublish
    }
    
    var subscriberChannelId: String? {
        return webSocketChannelPublisher.subscriberChannel?.id
    }
    
    var didCreateChannelPublisher: AnyPublisher<WebSocketChannel, TractRemoteSharePublisherError> {
        return didCreateChannelSubject
            .eraseToAnyPublisher()
    }
    
    func createNewSubscriberChannelIdForPublish() -> AnyPublisher<WebSocketChannel, TractRemoteSharePublisherError> {
        
        endPublishingSession(disconnectSocket: false)
                
        let channel = WebSocketChannel.getUniqueChannel()
                
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: Self.timeoutIntervalSeconds, repeats: false) { [weak self] _ in
            
            self?.stopTimeoutTimer()
            
            self?.didCreateChannelSubject.send(completion: .failure(.timedOut))
        }
        
        webSocketChannelPublisher
            .createChannelPublisher(url: remoteUrl, channel: channel)
            .sink { completion in
                
            } receiveValue: { [weak self] (channel: WebSocketChannel) in
                
                self?.stopTimeoutTimer()
                                
                self?.tractRemoteShareChannel = channel
                
                self?.didCreateChannelSubject.send(channel)
                self?.didCreateChannelSubject.send(completion: .finished)
            }
            .store(in: &cancellables)
        
        return didCreateChannelSubject
            .eraseToAnyPublisher()
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
