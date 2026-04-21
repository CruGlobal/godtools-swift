//
//  FollowUpsApiInterface.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation

protocol FollowUpsApiInterface {
    
    func postFollowUp(followUp: FollowUp, requestPriority: RequestPriority) async throws -> RequestDataResponse
}
