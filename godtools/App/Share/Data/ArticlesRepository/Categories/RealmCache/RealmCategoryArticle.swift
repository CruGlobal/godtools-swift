//
//  RealmCategoryArticle.swift
//  godtools
//
//  Created by Levi Eggert on 3/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmCategoryArticle: Object, CategoryArticleModelType {
    
    @objc dynamic var aemTag: String = ""
    @objc dynamic var categoryId: String = ""
    @objc dynamic var languageCode: String = ""
    @objc dynamic var uuid: String = ""
    
    let aemUris = List<String>()
    
    override static func primaryKey() -> String? {
        return "uuid"
    }
}
