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
    let languageId: String
    
    init(id: String, languageId: String) {
        
        self.id = id
        self.languageId = languageId
    }
    
    init(realmUserAppLanguage: RealmUserAppLanguage) {
        
        id = realmUserAppLanguage.id
        languageId = realmUserAppLanguage.languageId
    }
}
