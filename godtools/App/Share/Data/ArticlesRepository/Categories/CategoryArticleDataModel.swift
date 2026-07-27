//
//  CategoryArticleDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

struct CategoryArticleDataModel: Sendable {
    
    struct UUID: Sendable {
        
        let uuidString: String
        
        init(categoryId: String, languageCode: String, aemTag: String) {
           
            uuidString = categoryId + "_" + languageCode + "_" + aemTag
        }
    }
    
    let id: String
    let aemTag: String
    let aemUris: [String]
    let categoryId: String
    let languageCode: String
    let uuid: UUID
    
    init(id: String, aemTag: String, aemUris: [String], categoryId: String, languageCode: String) {
        
        self.id = id
        self.aemTag = aemTag
        self.aemUris = aemUris
        self.categoryId = categoryId
        self.languageCode = languageCode
        self.uuid = UUID(categoryId: categoryId, languageCode: languageCode, aemTag: aemTag)
    }
}

extension CategoryArticleDataModel.UUID: Equatable {
    static func == (this: CategoryArticleDataModel.UUID, that: CategoryArticleDataModel.UUID) -> Bool {
        return this.uuidString == that.uuidString
    }
}
