//
//  MobileContentApiError.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

enum MobileContentApiError: Error {
    
    case other(error: Error)
    case responseError(responseErrors: [MobileContentApiErrorCodable], error: Error)
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
