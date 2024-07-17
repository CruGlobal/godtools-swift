//
//  UserAppLanguageDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct UserAppLanguageDataModel {
    
    let id: String
    let languageId: BCP47LanguageIdentifier
    
    init(id: String, languageId: BCP47LanguageIdentifier) {
        
        self.id = id
        self.languageId = languageId
    }
    
    init(realmUserAppLanguage: RealmUserAppLanguage) {
        
        id = realmUserAppLanguage.id
        languageId = realmUserAppLanguage.languageId
    }
}
