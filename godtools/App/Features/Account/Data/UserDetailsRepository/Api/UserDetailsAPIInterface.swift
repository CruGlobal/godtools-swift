//
//  UserDetailsAPIInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 8/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation

protocol UserDetailsAPIInterface {
    func fetchUserDetailsPublisher(requestPriority: RequestPriority) -> AnyPublisher<MobileContentApiUsersMeCodable, Error>
    func deleteAuthUserDetailsPublisher(requestPriority: RequestPriority) -> AnyPublisher<Void, Error>
}
