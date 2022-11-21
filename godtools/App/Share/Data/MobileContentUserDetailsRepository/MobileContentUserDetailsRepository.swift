//
//  MobileContentUserDetailsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class MobileContentUserDetailsRepository {
    
    private let api: MobileContentUserDetailsAPI
    
    init(api: MobileContentUserDetailsAPI) {
        self.api = api
    }
    
    func fetchRemoteUserDetails() -> AnyPublisher<UserDataModel, URLResponseError> {
        
        return api.fetchUserDetailsPublisher()
    }
}
