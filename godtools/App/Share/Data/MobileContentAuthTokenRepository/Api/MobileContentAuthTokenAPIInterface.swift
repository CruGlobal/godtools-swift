//
//  MobileContentAuthTokenApiInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 8/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

protocol MobileContentAuthTokenApiInterface {
    
    func fetchAuthToken(providerToken: MobileContentAuthProviderToken, createUser: Bool) async throws -> Result<MobileContentAuthTokenDecodable, MobileContentApiError>
}
