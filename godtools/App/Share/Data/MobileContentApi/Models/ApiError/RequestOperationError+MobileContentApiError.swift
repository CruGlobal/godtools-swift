//
//  RequestOperationError+MobileContentApiError.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RequestOperation

extension Error {
    
    func decodeRequestOperationErrorToMobileContentApiError() -> MobileContentApiError {
                
        guard let responseData = getRequestOperationUrlRequestResponseData() else {
            return .other(error: self)
        }
                
        do {
            
            let object: MobileContentApiErrorsCodable = try JSONDecoder().decode(MobileContentApiErrorsCodable.self, from: responseData)
            return .responseError(responseErrors: object.errors, error: self)
        }
        catch let decodeError {
            
            return .other(error: decodeError)
        }
    }
}
