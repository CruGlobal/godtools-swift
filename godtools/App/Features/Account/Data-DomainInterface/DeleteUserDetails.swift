//
//  DeleteUserDetails.swift
//  godtools
//
//  Created by Levi Eggert on 5/12/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class DeleteUserDetails: DeleteUserDetailsInterface {
    
    private let userDetailsRepository: UserDetailsRepository
    
    init(userDetailsRepository: UserDetailsRepository) {
        
        self.userDetailsRepository = userDetailsRepository
    }
    
    func deleteUserDetailsPublisher() -> AnyPublisher<Void, Error> {
        
        return userDetailsRepository.deleteAuthUserDetailsPublisher(requestPriority: .high)
            .eraseToAnyPublisher()
    }
}
