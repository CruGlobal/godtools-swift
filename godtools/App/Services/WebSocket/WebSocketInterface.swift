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
        
    var didReceiveTextPublisher: AnyPublisher<String, Never> { get }
    var connectionState: WebSocketConnectionState { get }
        
    func connectPublisher(url: URL) -> AnyPublisher<Void, Error>
    func disconnect()
    func write(string: String)
}
