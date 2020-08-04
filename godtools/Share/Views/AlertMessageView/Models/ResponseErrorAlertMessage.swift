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
    
    init(localizationServices: LocalizationServices, error: ResponseError<NoClientApiErrorType>) {
        
        switch error {
            
        case .httpClientError(let clientError):
            title = localizationServices.stringForMainBundle(key: "error")
            message = "An unknown error occurred on the client api."
        
        case .noNetworkConnection:
            title = localizationServices.stringForMainBundle(key: "no_internet_title")
            message = localizationServices.stringForMainBundle(key: "no_internet")
        
        case .requestCancelled:
            title = localizationServices.stringForMainBundle(key: "error")
            message = "The request was cancelled."
        
        case .requestFailed(let error):
            title = localizationServices.stringForMainBundle(key: "error")
            message = error.localizedDescription
        }
    }
}
