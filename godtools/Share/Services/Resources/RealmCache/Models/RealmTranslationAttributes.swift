//
//  RealmTranslationAttributes.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmTranslationAttributes: Object, TranslationAttributesType {
    
    @objc dynamic var isPublished: Bool = false
    @objc dynamic var manifestName: String?
    @objc dynamic var translatedDescription: String?
    @objc dynamic var translatedName: String?
    @objc dynamic var translatedTagline: String?
    @objc dynamic var version: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case isPublished = "is-published"
        case manifestName = "manifest-name"
        case translatedDescription = "translated-description"
        case translatedName = "translated-name"
        case translatedTagline = "translated-tagline"
        case version = "version"
    }
}
