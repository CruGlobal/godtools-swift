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
    
    func fetchAuthTokenPublisher(providerToken: MobileContentAuthProviderToken, createUser: Bool) -> AnyPublisher<MobileContentAuthTokenDecodable, MobileContentApiError>
}
