//
//  OktaAuthenticationError+GetError.swift
//  godtools
//
//  Created by Levi Eggert on 10/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import OktaAuthentication

extension OktaAuthenticationError {
    
    func getError() -> Error {
        
        switch self {
        case .internalError(let error, let message):
            
            if let error = error {
                return error
            }
            
            return NSError.errorWithDescription(description: message)
            
        case .oktaSdkError(let error):
            return error
        }
    }
}
