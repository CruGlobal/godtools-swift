//
//  RealmLanguageAttributes.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmLanguageAttributes: Object, LanguageAttributesType {
    
    @objc dynamic var code: String?
    @objc dynamic var name: String?
    @objc dynamic var direction: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case name = "name"
        case direction = "direction"
    }
}
