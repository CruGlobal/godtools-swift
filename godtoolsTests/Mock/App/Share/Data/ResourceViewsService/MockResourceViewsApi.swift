//
//  MockResourceViewsApi.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import RequestOperation

final class MockResourceViewsApi: ResourceViewsApiInterface {
    
    let result: Result<RequestDataResponse, Error>
    
    init(result: Result<RequestDataResponse, Error>) {
        
        self.result = result
    }
    
    func postResourceView(resourceId: String, quantity: Int, requestPriority: RequestPriority) async throws -> RequestDataResponse {
        
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}
