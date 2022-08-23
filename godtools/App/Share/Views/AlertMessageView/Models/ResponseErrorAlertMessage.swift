//
//  ResponseErrorAlertMessage.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

@available(*, deprecated) // TODO: RequestOperation won't be needed as we move to Combine Publishers.  Flow+NetworkErrorAlert can be used for presenting URLResponseError's. ~Levi
struct ResponseErrorAlertMessage: AlertMessageType {
    
    let title: String
    let message: String
    
    init(localizationServices: LocalizationServices, error: RequestResponseError<NoHttpClientErrorResponse>) {
        
        switch error {
            
        case .httpClientError(_, _, _):
            title = localizationServices.stringForMainBundle(key: "error")
            message = "An unknown error occurred on the client api."
        
        case .noNetworkConnection:
            title = localizationServices.stringForMainBundle(key: "no_internet_title")
            message = localizationServices.stringForMainBundle(key: "no_internet")
            
        case .notAuthorized:
            title = localizationServices.stringForMainBundle(key: "error")
            message = "Not authorized."
        
        case .requestCancelled:
            title = localizationServices.stringForMainBundle(key: "error")
            message = "The request was cancelled."
        
        case .requestError(let error):
            title = localizationServices.stringForMainBundle(key: "error")
            message = error.localizedDescription
            
        case .serverError(let httpStatusCode):
            title = localizationServices.stringForMainBundle(key: "error")
            message = "Server Error \(httpStatusCode)."
        }
    }
}
