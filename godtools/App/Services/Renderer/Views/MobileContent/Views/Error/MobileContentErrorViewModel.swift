//
//  MobileContentErrorViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentErrorViewModel {
    
    let title: String
    let message: String
    let acceptTitle: String
    
    init(title: String, message: String, localizationServices: LocalizationServices) {
        
        self.title = title
        self.message = message
        self.acceptTitle = localizationServices.stringForSystemElseEnglish(key: "OK")
    }
}
