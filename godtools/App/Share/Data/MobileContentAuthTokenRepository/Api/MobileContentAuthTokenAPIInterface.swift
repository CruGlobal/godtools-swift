//
//  MobileContentAuthTokenAPIInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 8/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

protocol MobileContentAuthTokenAPIInterface {
    
    func fetchAuthToken(providerToken: MobileContentAuthProviderToken, createUser: Bool) async throws -> Result<MobileContentAuthTokenDecodable, MobileContentApiError>
    func fetchAuthTokenPublisher(providerToken: MobileContentAuthProviderToken, createUser: Bool) -> AnyPublisher<MobileContentAuthTokenDecodable, MobileContentApiError>
}
