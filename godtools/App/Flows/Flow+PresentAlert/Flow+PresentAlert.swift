//
//  Flow+PresentAlert.swift
//  godtools
//
//  Created by Levi Eggert on 5/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

extension GTFlow {
    
    func presentAlertMessage(
        appLanguage: AppLanguageDomainModel,
        alertMessage: AlertMessage,
        acceptTapped: (() -> Void)? = nil
    ) {
        
        presentAlert(
            appLanguage: appLanguage,
            title: alertMessage.title,
            message: alertMessage.message,
            acceptTapped: acceptTapped
        )
    }
    
    func presentAlert(
        appLanguage: AppLanguageDomainModel,
        title: String,
        message: String,
        acceptTapped: (() -> Void)? = nil
    ) {

        let localizationServices: LocalizationServicesInterface = appDiContainer.core.dataLayer.getLocalizationServices()

        let acceptTitleKey: String = LocalizableStringKeys.ok.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                acceptTitleKey
            ],
            fetchOrder: localizationServices.getDefaultFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: localizationServices.defaultFallbackToKey
        )

        let view = AlertMessageView(
            title: title,
            message: message,
            acceptTitle: strings[acceptTitleKey] ?? "",
            cancelTitle: nil,
            acceptTapped: acceptTapped,
            cancelTapped: nil
        )

        presentView(view: view.controller, animated: true, completion: nil)
    }
}
