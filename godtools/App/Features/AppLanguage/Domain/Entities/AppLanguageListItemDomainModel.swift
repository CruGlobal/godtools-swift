//
//  AppLanguageListItemDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct AppLanguageListItemDomainModel {
    
    let languageCode: AppLanguageCodeDomainModel
    let languageNameTranslatedInOwnLanguage: String
    let languageNameTranslatedInCurrentAppLanguage: String
}

extension AppLanguageListItemDomainModel: Identifiable {
    var id: String {
        return languageCode
    }
}
