//
//  RequestDataResponse+WithHttpStatusCode.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import RequestOperation

extension RequestDataResponse {
    
    static func createWithHttpStatusCode(httpStatusCode: Int, data: Data = Data(), urlString: String = "https://godtoolsapp.com") throws -> RequestDataResponse {
        
        guard let url = URL(string:urlString) else {
            throw NSError.errorWithDescription(description: "Failed to create url.")
        }
        
        guard let httpUrlResponse = HTTPURLResponse(
            url: URL(string:"https://godtoolsapp.com")!,
            statusCode: httpStatusCode,
            httpVersion: nil,
            headerFields: nil
        ) else {
            throw NSError.errorWithDescription(description: "Failed to httpUrlResponse.")
        }
        
        return RequestDataResponse(
            data: data,
            urlResponse: httpUrlResponse
        )
    }
}
