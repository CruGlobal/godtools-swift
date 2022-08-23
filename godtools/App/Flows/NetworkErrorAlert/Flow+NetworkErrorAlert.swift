//
//  Flow+NetworkErrorAlert.swift
//  godtools
//
//  Created by Levi Eggert on 8/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

extension Flow {
    
    func presentNetworkError(responseError: URLResponseError) {
        
        guard !responseError.getError().requestCancelled else {
            return
        }
        
        let localizationServices: LocalizationServices = appDiContainer.localizationServices
        
        let title: String
        let message: String
        
        if responseError.getError().notConnectedToInternet {

            title = localizationServices.stringForMainBundle(key: "no_internet_title")
            message = localizationServices.stringForMainBundle(key: "no_internet")
        }
        else {
            
            title = localizationServices.stringForMainBundle(key: "error")
            
            switch responseError {
            case .decodeError( _):
                message = localizationServices.stringForMainBundle(key: "download_error")
            case .otherError( _):
                message = localizationServices.stringForMainBundle(key: "download_error")
            case .requestError(let error):
                message = error.localizedDescription
            case .statusCode(let urlResponseObject):
                message = "Server Error \(String(describing: urlResponseObject.httpStatusCode))."
            }
        }
        
        let viewModel = AlertMessageViewModel(
            title: title,
            message: message,
            cancelTitle: nil,
            acceptTitle: localizationServices.stringForMainBundle(key: "OK"),
            acceptHandler: nil
        )
        
        let view = AlertMessageView(viewModel: viewModel)
        
        navigationController.present(view.controller, animated: true, completion: nil)
    }
}
