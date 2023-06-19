//
//  Flow+NetworkErrorAlert.swift
//  godtools
//
//  Created by Levi Eggert on 8/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

extension Flow {
    
    func presentNetworkError(responseError: Error) {
        
        let isCancelled: Bool = responseError.isUrlErrorCancelledCode
        
        guard !isCancelled else {
            return
        }
        
        let localizationServices: LocalizationServices = appDiContainer.localizationServices
        
        let title: String
        let message: String
        
        if responseError.isUrlErrorNotConnectedToInternetCode {

            title = localizationServices.stringForMainBundle(key: "no_internet_title")
            message = localizationServices.stringForMainBundle(key: "no_internet")
        }
        else {
            
            title = localizationServices.stringForMainBundle(key: "error")
            message = responseError.localizedDescription
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
