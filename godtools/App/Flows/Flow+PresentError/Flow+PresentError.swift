//
//  Flow+PresentError.swift
//  godtools
//
//  Created by Levi Eggert on 5/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

extension GTFlow {
    
    func presentError(appLanguage: AppLanguageDomainModel, error: Error, acceptTapped: (() -> Void)? = nil) {

        let isCancelled: Bool = error.isUrlErrorCancelledCode || error.isUserCancelled

        guard !isCancelled else {
            return
        }

        let localizationServices: LocalizationServicesInterface = appDiContainer.core.dataLayer.getLocalizationServices()

        let noInternetTitleKey: String = LocalizableStringKeys.noInternetTitle.key
        let noInternetKey: String = LocalizableStringKeys.noInternet.key
        let networkConnectionLostKey: String = LocalizableStringKeys.networkConnectionLost.key
        let errorKey: String = LocalizableStringKeys.error.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                noInternetTitleKey,
                noInternetKey,
                networkConnectionLostKey,
                errorKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        let title: String
        let message: String

        if error.isUrlErrorNotConnectedToInternetCode {

            title = strings[noInternetTitleKey] ?? ""
            message = strings[noInternetKey] ?? ""
        }
        else if error.isNetworkConnectionLost {

            title = strings[noInternetTitleKey] ?? ""
            message = strings[networkConnectionLostKey] ?? ""
        }
        else {

            title = strings[errorKey] ?? ""
            message = error.localizedDescription + "\n error code: \(error.code)"
        }

        presentAlert(
            appLanguage: appLanguage,
            title: title,
            message: message,
            acceptTapped: acceptTapped
        )
    }
}
