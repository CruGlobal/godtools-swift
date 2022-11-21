//
//  GetMobileContentUserDetails.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetMobileContentUserDetails {
    
    private let repository: MobileContentUserDetailsRepository
    
    init(repository: MobileContentUserDetailsRepository) {
        
        self.repository = repository
    }
    
    
    func getUserDetailsPublisher() -> AnyPublisher<UserDataModel, URLResponseError> {
        
        return repository.fetchRemoteUserDetails()
    }
}
