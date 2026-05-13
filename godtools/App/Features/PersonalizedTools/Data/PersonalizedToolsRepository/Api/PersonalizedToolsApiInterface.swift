//
//  PersonalizedToolsApiInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/11/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation

protocol PersonalizedToolsApiInterface {
    
    typealias TwoLetterCountryCode = String
    typealias TwoLetterLanguageCode = String
    
    func getAllRankedResources(requestPriority: RequestPriority, country: TwoLetterCountryCode?, language: TwoLetterLanguageCode?, resourceTypes: [ResourceType]?) async throws -> [ResourceCodable]
    func getDefaultOrderResources(requestPriority: RequestPriority, language: TwoLetterLanguageCode?, resourceTypes: [ResourceType]?) async throws -> [ResourceCodable]
}
