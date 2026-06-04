//
//  Flow+PresentAlert.swift
//  godtools
//
//  Created by Levi Eggert on 5/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

extension LegacyFlow {
    
    func presentAlertMessage(appLanguage: AppLanguageDomainModel, alertMessage: AlertMessage) {
        
        presentAlert(appLanguage: appLanguage, title: alertMessage.title, message: alertMessage.message)
    }
    
    func presentAlert(appLanguage: AppLanguageDomainModel, title: String, message: String) {
        
        let localizationServices: LocalizationServicesInterface = appDiContainer.core.dataLayer.getLocalizationServices()
                
        let view = AlertMessageView(
            title: title,
            message: message,
            acceptTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.ok.key),
            cancelTitle: nil,
            acceptTapped: nil,
            cancelTapped: nil
        )
        
        navigationController.present(view.controller, animated: true, completion: nil)
    }
}
