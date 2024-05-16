//
//  Flow+NetworkErrorAlert.swift
//  godtools
//
//  Created by Levi Eggert on 8/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

extension Flow {
    
    func presentNetworkError(appLanguage: AppLanguageDomainModel, responseError: Error) {
        
        let isCancelled: Bool = responseError.isUrlErrorCancelledCode
        
        guard !isCancelled else {
            return
        }
        
        let localizationServices: LocalizationServices = appDiContainer.dataLayer.getLocalizationServices()
        
        let title: String
        let message: String
        
        if responseError.isUrlErrorNotConnectedToInternetCode {

            title = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.noInternetTitle.key)
            message = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.noInternet.key)
        }
        else {
            
            title = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.error.key)
            message = responseError.localizedDescription
        }
        
        let viewModel = AlertMessageViewModel(
            title: title,
            message: message,
            cancelTitle: nil,
            acceptTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.ok.key),
            acceptHandler: nil
        )
        
        let view = AlertMessageView(viewModel: viewModel)
        
        navigationController.present(view.controller, animated: true, completion: nil)
    }
}
