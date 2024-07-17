//
//  Flow+PresentAlert.swift
//  godtools
//
//  Created by Levi Eggert on 5/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import LocalizationServices

extension Flow {
    
    func presentAlertMessage(appLanguage: AppLanguageDomainModel, alertMessage: AlertMessageType) {
        
        presentAlert(appLanguage: appLanguage, title: alertMessage.title, message: alertMessage.message)
    }
    
    func presentAlert(appLanguage: AppLanguageDomainModel, title: String, message: String) {
        
        let localizationServices: LocalizationServices = appDiContainer.dataLayer.getLocalizationServices()
                
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
