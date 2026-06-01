//
//  UserDetailsApiInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation

protocol UserDetailsApiInterface {
    
    func fetchUserDetails(requestPriority: RequestPriority) async throws -> MobileContentApiUsersMeCodable
    func deleteAuthUserDetails(requestPriority: RequestPriority) async throws
}
