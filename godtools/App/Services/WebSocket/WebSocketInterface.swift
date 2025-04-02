//
//  WebSocketInterface.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

protocol WebSocketInterface {
        
    var didReceiveTextSignal: SignalValue<String> { get }
    var isConnected: Bool { get }
        
    func connectPublisher(url: URL) -> AnyPublisher<Void, Error>
    func disconnect()
    func write(string: String)
}
