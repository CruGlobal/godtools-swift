//
//  GetUserIsAuthenticatedUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetUserIsAuthenticatedUseCase {
    
    private let userAuthentication: UserAuthentication
    private let mobileContentAuthTokenRepository: MobileContentAuthTokenRepository
    
    init(userAuthentication: UserAuthentication, mobileContentAuthTokenRepository: MobileContentAuthTokenRepository) {
        
        self.userAuthentication = userAuthentication
        self.mobileContentAuthTokenRepository = mobileContentAuthTokenRepository
    }
    
    func getIsAuthenticatedPublisher() -> AnyPublisher<UserIsAuthenticatedDomainModel, Never> {
        
        return mobileContentAuthTokenRepository.getAuthTokenChangedPublisher()
            .map {
                return self.mapToDomainModel(authToken: $0)
            }
            .eraseToAnyPublisher()
    }
    
    private func mapToDomainModel(authToken: MobileContentAuthTokenDataModel?) -> UserIsAuthenticatedDomainModel {
        
        let isAuthenticated: Bool
        
        if let authToken = authToken {
            
            isAuthenticated = !authToken.isExpired
        }
        else {
            
            isAuthenticated = false
        }
        
        return UserIsAuthenticatedDomainModel(
            isAuthenticated: isAuthenticated
        )
    }
}
