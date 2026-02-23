//
//  MobileContentApiError.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

enum MobileContentApiError: Error, Sendable {
    
    case other(error: Error)
    case responseError(responseErrors: [MobileContentApiErrorCodable], error: Error = NSError.errorWithDescription(description: "Bad request from mobile content api.  Check responseErrors: [MobileContentApiErrorCodable]."))
}

extension MobileContentApiError {
    
    func getError() -> Error {
        switch self {
        case .other(let error):
            return error
        case .responseError( _, let error):
            return error
        }
    }
    
    func getErrorDescription() -> String {
        return getError().localizedDescription
    }
}


extension MobileContentApiError {
 
    func toAuthError() -> AuthErrorDomainModel {
       
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
