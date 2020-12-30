//
//  ResponseError.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum ResponseError<ClientApiErrorType: Decodable>: Error {
    
    case httpClientError(error: ClientApiErrorType?)
    case noNetworkConnection
    case requestCancelled
    case requestFailed(error: Error)
    
    var cancelled: Bool {
        switch self {
        case .requestCancelled:
            return true
        default:
            return false
        }
    }
}
