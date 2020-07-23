//
//  WebSocketType.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol WebSocketType {
        
    var didConnectSignal: Signal { get }
    var didDisconnectSignal: Signal { get }
    var didReceiveTextSignal: SignalValue<String> { get }
    var didReceiveJsonSignal: SignalValue<[String: Any]> { get }
    var isConnected: Bool { get }
        
    func connect(url: URL)
    func disconnect()
    func write(string: String)
}
