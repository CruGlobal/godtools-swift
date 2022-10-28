//
//  CruOktaAuthentication+GetAuthUser.swift
//  godtools
//
//  Created by Levi Eggert on 10/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import OktaAuthentication
import Combine

extension CruOktaAuthentication {
    
    func getAuthUserPublisher() -> AnyPublisher<CruOktaUserDataModel, OktaAuthenticationError> {
        
        return getAuthorizedUserJsonObjectPublisher()
            .map{ data in
                
                return CruOktaUserDataModel(
                    email: data["email"] as? String ?? "",
                    firstName: data["given_name"] as? String,
                    grMasterPersonId: data["grMasterPersonId"] as? String,
                    lastName: data["family_name"] as? String,
                    ssoGuid: data["ssoguid"] as? String
                )
            }
            .eraseToAnyPublisher()
    }
}
