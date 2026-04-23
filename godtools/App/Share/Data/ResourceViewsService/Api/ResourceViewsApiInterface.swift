//
//  ResourceViewsApiInterface.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation

protocol ResourceViewsApiInterface {
    
    func postResourceView(resourceId: String, quantity: Int, requestPriority: RequestPriority) async throws -> RequestDataResponse
}
