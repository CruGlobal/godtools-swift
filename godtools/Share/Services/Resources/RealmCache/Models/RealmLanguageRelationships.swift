//
//  RealmLanguageRelationships.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmLanguageRelationships: Object, LanguageRelationshipsType {
    
    @objc dynamic var languageTranslations: RealmLanguageTranslations?
    
    enum CodingKeys: String, CodingKey {
        case languageTranslations = "translations"
    }
}
