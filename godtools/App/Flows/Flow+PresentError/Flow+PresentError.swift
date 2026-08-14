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

        Task {

            let title: String
            let message: String

            if error.isUrlErrorNotConnectedToInternetCode {

                title = await localizationServices.stringForLocaleElseEnglish(
                    localeIdentifier: appLanguage,
                    key: LocalizableStringKeys.noInternetTitle.key
                )

                message = await localizationServices.stringForLocaleElseEnglish(
                    localeIdentifier: appLanguage,
                    key: LocalizableStringKeys.noInternet.key
                )
            }
            else if error.isNetworkConnectionLost {

                title = await localizationServices.stringForLocaleElseEnglish(
                    localeIdentifier: appLanguage,
                    key: LocalizableStringKeys.noInternetTitle.key
                )

                message = await localizationServices.stringForLocaleElseEnglish(
                    localeIdentifier: appLanguage,
                    key: LocalizableStringKeys.networkConnectionLost.key
                )
            }
            else {

                title = await localizationServices.stringForLocaleElseEnglish(
                    localeIdentifier: appLanguage,
                    key: LocalizableStringKeys.error.key
                )

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
}
