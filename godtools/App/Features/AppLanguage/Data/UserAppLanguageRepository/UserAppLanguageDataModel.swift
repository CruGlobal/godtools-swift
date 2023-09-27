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
    let languageCode: String
    
    init(id: String, languageCode: String) {
        
        self.id = id
        self.languageCode = languageCode
    }
    
    init(realmUserAppLanguage: RealmUserAppLanguage) {
        
        id = realmUserAppLanguage.id
        languageCode = realmUserAppLanguage.languageCode
    }
}
