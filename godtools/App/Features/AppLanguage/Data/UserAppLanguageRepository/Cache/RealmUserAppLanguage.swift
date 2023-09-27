//
//  RealmUserAppLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmUserAppLanguage: Object {
    
    @objc dynamic var id: String = ""
    @objc dynamic var languageCode: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(appLanguage: UserAppLanguageDataModel) {
        
        id = appLanguage.id
        languageCode = appLanguage.languageCode
    }
}
