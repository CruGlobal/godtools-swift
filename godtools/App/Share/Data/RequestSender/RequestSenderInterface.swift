//
//  RequestSenderInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation

protocol RequestSenderInterface: Sendable {
    
    func sendDataTask(urlRequest: URLRequest, urlSession: URLSession) async throws -> RequestDataResponse
}
