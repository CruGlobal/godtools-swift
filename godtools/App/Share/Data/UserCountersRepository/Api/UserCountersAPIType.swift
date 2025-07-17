//
//  UserCountersAPIType.swift
//  godtools
//
//  Created by Rachael Skeath on 4/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation

protocol UserCountersAPIType {
    
    func fetchUserCountersPublisher(requestPriority: RequestPriority) -> AnyPublisher<[UserCounterDecodable], Error>
    func incrementUserCounterPublisher(id: String, increment: Int, requestPriority: RequestPriority) -> AnyPublisher<UserCounterDecodable, Error>
}
