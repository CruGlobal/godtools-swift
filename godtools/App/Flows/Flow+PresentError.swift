//
//  Flow+PresentError.swift
//  godtools
//
//  Created by Levi Eggert on 5/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

extension Flow {
    
    func presentError(error: Error) {
        
        let localizationServices: LocalizationServices = appDiContainer.dataLayer.getLocalizationServices()
        
        let title: String = localizationServices.stringForMainBundle(key: "error")
        let message: String = error.localizedDescription
        
        let viewModel = AlertMessageViewModel(
            title: title,
            message: message,
            cancelTitle: nil,
            acceptTitle: localizationServices.stringForMainBundle(key: "OK"),
            acceptHandler: nil
        )
        
        let view = AlertMessageView(viewModel: viewModel)
        
        navigationController.present(view.controller, animated: true, completion: nil)
    }
}
