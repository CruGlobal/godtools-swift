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
        
    var didConnectPublisher: AnyPublisher<Void, Never> { get }
    var didReceiveTextPublisher: AnyPublisher<String, Never> { get }
    var url: URL { get }
    var connectionState: WebSocketConnectionState { get }
        
    init(url: URL)
    
    func connect()
    func disconnect()
    func write(string: String)
}
