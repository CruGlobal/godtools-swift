//
//  DeleteAccountUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class DeleteAccountUseCase {
    
    private let userAuthentication: UserAuthentication
    private let userDetailsRepository: UserDetailsRepository
    
    init(userAuthentication: UserAuthentication, userDetailsRepository: UserDetailsRepository) {
        
        self.userAuthentication = userAuthentication
        self.userDetailsRepository = userDetailsRepository
    }
    
    func execute() async throws {
        
        _ = try await userDetailsRepository.deleteAuthUserDetails(requestPriority: .high)
        
        try await userAuthentication.signOut()
    }
}
