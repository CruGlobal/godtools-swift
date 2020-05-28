//
//  RealmLanguageTranslations.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmLanguageTranslations: Object, LanguageTranslationsType {
    
    let data = List<RealmTranslation>()
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let translations = try container.decode([RealmTranslation].self, forKey: .data)
        data.append(objectsIn: translations)
        
        super.init()
    }
    
    required init() {
        super.init()
    }
}
