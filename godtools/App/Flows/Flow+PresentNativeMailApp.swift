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
    
    func navigateToNativeMailApp(viewModel: MailViewModelType) {
        
        guard MFMailComposeViewController.canSendMail() else {
                        
            let localizationServices: LocalizationServices = appDiContainer.localizationServices
            
            let viewModel = AlertMessageViewModel(
                title: localizationServices.stringForMainBundle(key: "alert.mailAppUnavailable.title"),
                message: localizationServices.stringForMainBundle(key: "alert.mailAppUnavailable.message"),
                cancelTitle: nil,
                acceptTitle: localizationServices.stringForMainBundle(key: "OK"),
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

