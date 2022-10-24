//
//  GetUserAccountProfileNameUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import OktaAuthentication
import Combine

class GetUserAccountProfileNameUseCase {
    
    private let cruOktaAuthentication: CruOktaAuthentication
    
    init(cruOktaAuthentication: CruOktaAuthentication) {
        
        self.cruOktaAuthentication = cruOktaAuthentication
    }
    
    func getProfileNamePublisher() -> AnyPublisher<AccountProfileNameDomainModel, Never> {
     
        return cruOktaAuthentication.getAuthUserPublisher()
            .catch({ (oktaError: OktaAuthenticationError) -> AnyPublisher<CruOktaUserDataModel, Never> in
                
                return Just(CruOktaUserDataModel(email: "", firstName: "", grMasterPersonId: "", lastName: "", ssoGuid: ""))
                    .eraseToAnyPublisher()
            })
            .flatMap({ (authUser: CruOktaUserDataModel) -> AnyPublisher<AccountProfileNameDomainModel, Never> in
                
                let profileName: String
                
                if let firstName = authUser.firstName, let lastName = authUser.lastName {
                    profileName = firstName + " " + lastName
                }
                else if let firstName = authUser.firstName {
                    profileName = firstName
                }
                else if let lastName = authUser.lastName {
                    profileName = lastName
                }
                else {
                    profileName = ""
                }
                
                return Just(AccountProfileNameDomainModel(value: profileName))
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
