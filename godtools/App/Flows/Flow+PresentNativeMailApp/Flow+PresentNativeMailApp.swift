//
//  Flow+PresentNativeMailApp.swift
//  godtools
//
//  Created by Levi Eggert on 7/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import MessageUI

extension Flow {
    
    func navigateToNativeMailApp(appLanguage: AppLanguageDomainModel, viewModel: MailViewModelType) {
        
        guard MFMailComposeViewController.canSendMail() else {
                        
            let localizationServices: LocalizationServices = appDiContainer.dataLayer.getLocalizationServices()
            
            let viewModel = AlertMessageViewModel(
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.alertMailAppUnavailableTitle.key),
                message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.alertMailAppUnavailableMessage.key),
                cancelTitle: nil,
                acceptTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.ok.key),
                acceptHandler: nil
            )
            
            let view = AlertMessageView(viewModel: viewModel)
            
            navigationController.present(view.controller, animated: true)
            
            return
        }
        
        let view = MailView(viewModel: viewModel)
        
        navigationController.present(view, animated: true)
    }
}

