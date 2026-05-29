//
//  MobileContentApiAuthSessionInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/29/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol MobileContentApiAuthSessionInterface: Sendable {
    
    func sendAuthenticatedRequest(urlRequest: URLRequest, urlSession: URLSession) async throws -> Data
}
