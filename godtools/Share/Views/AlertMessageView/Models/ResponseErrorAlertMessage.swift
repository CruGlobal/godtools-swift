//
//  ResponseErrorAlertMessage.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ResponseErrorAlertMessage: AlertMessageType {
    
    let title: String
    let message: String
    
    init(error: ResponseError<NoClientApiErrorType>) {
        
        switch error {
            
        case .httpClientError(let error):
            title = NSLocalizedString("error", comment: "")
            message = "An unknown error occurred on the client api."
        
        case .noNetworkConnection:
            title = NSLocalizedString("no_internet_title", comment: "")
            message = NSLocalizedString("no_internet", comment: "")
        
        case .requestCancelled:
            title = NSLocalizedString("error", comment: "")
            message = "The request was cancelled."
        
        case .requestFailed(let error):
            title = NSLocalizedString("error", comment: "")
            message = error.localizedDescription
        }
    }
}
