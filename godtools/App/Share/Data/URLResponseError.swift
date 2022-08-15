//
//  URLResponseError.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

enum URLResponseError: Error {

    case decodeError(error: Error)
    case otherError(error: Error)
    case requestError(error: Error)
    case statusCode(urlResponseObject: URLResponseObject)
    
    func getErrorMessage() -> String {
        
        switch self {
            
        case .decodeError(let error):
            return "Decode error: \(error)"
            
        case .otherError(let error):
            return "Other error: \(error)"
            
        case .requestError(let error):
            return "Request error: \(error)"
            
        case .statusCode(let urlResponseObject):
            return "HTTP status code error.\n httpStatusCode: \(String(describing: urlResponseObject.httpStatusCode))"
        }
    }
}
