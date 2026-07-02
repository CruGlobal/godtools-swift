//
//  CategoryArticleModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

struct CategoryArticleModel: Sendable {
    
    let id: String
    let aemTag: String
    let aemUris: [String]
    let categoryId: String
    let languageCode: String
    let uuid: CategoryArticleUUID
    
    init(id: String, aemTag: String, aemUris: [String], categoryId: String, languageCode: String) {
        
        self.id = id
        self.aemTag = aemTag
        self.aemUris = aemUris
        self.categoryId = categoryId
        self.languageCode = languageCode
        self.uuid = CategoryArticleUUID(categoryId: categoryId, languageCode: languageCode, aemTag: aemTag)
    }
}
