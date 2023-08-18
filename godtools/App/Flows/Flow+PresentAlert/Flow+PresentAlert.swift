//
//  Flow+PresentAlert.swift
//  godtools
//
//  Created by Levi Eggert on 5/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

extension Flow {
    
    func presentAlert(title: String, message: String) {
        
        let localizationServices: LocalizationServices = appDiContainer.dataLayer.getLocalizationServices()
                
        let viewModel = AlertMessageViewModel(
            title: title,
            message: message,
            cancelTitle: nil,
            acceptTitle: localizationServices.stringForSystemElseEnglish(key: "OK"),
            acceptHandler: nil
        )
        
        let view = AlertMessageView(viewModel: viewModel)
        
        navigationController.present(view.controller, animated: true, completion: nil)
    }
}
