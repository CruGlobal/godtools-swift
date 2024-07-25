//
//  UserCountersAPIType.swift
//  godtools
//
//  Created by Rachael Skeath on 4/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol UserCountersAPIType {
    
    func fetchUserCountersPublisher() -> AnyPublisher<[UserCounterDecodable], Error>
    func incrementUserCounterPublisher(id: String, increment: Int) -> AnyPublisher<UserCounterDecodable, Error>
}
