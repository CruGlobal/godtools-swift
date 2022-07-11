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
            
            // TODO: Present alert that native Mail app is not configured or available on the device. ~Levi
            
            return
        }
        
        let view = MailView(viewModel: viewModel)
        
        navigationController.present(view, animated: true)
    }
}

