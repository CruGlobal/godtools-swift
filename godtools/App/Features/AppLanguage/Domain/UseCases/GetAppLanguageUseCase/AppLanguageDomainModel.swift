//
//  AppLanguageDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct AppLanguageDomainModel {
    
    let direction: LanguageDirectionDomainModel
    let languageCode: String
}

extension AppLanguageDomainModel: Identifiable {
    
    var id: String {
        return languageCode
    }
}