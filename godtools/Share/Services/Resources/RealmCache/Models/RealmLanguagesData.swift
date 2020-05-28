//
//  RealmLanguagesData.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmLanguagesData: Object, LanguagesDataType {
    
    @objc dynamic var id: String = "shared"
    let data = List<RealmLanguage>()
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let languages = try container.decode([RealmLanguage].self, forKey: .data)
        data.append(objectsIn: languages)
        
        super.init()
    }
    
    required init() {
        super.init()
    }
}
