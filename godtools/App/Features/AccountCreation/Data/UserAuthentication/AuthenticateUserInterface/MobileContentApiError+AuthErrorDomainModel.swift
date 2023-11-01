//
//  MobileContentApiError+AuthErrorDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

extension MobileContentApiError {
    
    func toAuthErrorDomainModel() -> AuthErrorDomainModel {
        
        switch self {
            
        case .other(let error):
            return .other(error: error)
            
        case .responseError(let responseErrors, let error):
            
            for responseError in responseErrors {
                
                let code: MobileContentApiErrorCodableCode = responseError.getCodeEnum()
                
                if code == .userNotFound {
                    return .accountNotFound
                }
                else if code == .userAlreadyExists {
                    return .accountAlreadyExists
                }
            }

            return .other(error: error)
        }
    }
}
