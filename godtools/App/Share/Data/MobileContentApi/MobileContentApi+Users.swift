//
//  MobileContentApi+Users.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

extension MobileContentApi {
    
    func deleteUsersMe(authToken: MobileContentApiAuthToken) -> AnyPublisher<EmptyCodable, Error> {
        
        let request = MobileContentApiRequest(
            path: "users/me",
            method: .delete,
            headers: MobileContentApiUrlRequestHeaders.authorizedHeaders(authToken: authToken),
            httpBody: nil,
            queryItems: nil
        )
        
        return sendRequest(request: request)
            .eraseToAnyPublisher()
    }
}
