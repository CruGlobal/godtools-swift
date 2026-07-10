//
//  FakeUserDatailsApi.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import RequestOperation

final class FakeUserDatailsApi: UserDetailsApiInterface {
    
    private var user: MobileContentApiUsersMeCodable
    
    init(user: MobileContentApiUsersMeCodable) {
        
        self.user = user
    }
    
    func fetchUserDetails(requestPriority: RequestPriority) async throws -> MobileContentApiUsersMeCodable {
        
        return user
    }
    
    func deleteAuthUserDetails(requestPriority: RequestPriority) async throws {
        
    }
}
