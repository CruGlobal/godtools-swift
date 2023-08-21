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
        
        let title: String = localizationServices.stringForSystemElseEnglish(key: "error")
        let message: String = error.localizedDescription
        
        presentAlert(title: title, message: message)
    }
}
