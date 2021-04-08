//
//  CategoryArticleUUID.swift
//  godtools
//
//  Created by Levi Eggert on 3/31/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

struct CategoryArticleUUID {
    
    let uuidString: String
    
    init(categoryId: String, languageCode: String, aemTag: String) {
       
        uuidString = categoryId + "_" + languageCode + "_" + aemTag
    }
}

extension CategoryArticleUUID: Equatable {
    static func ==(lhs: CategoryArticleUUID, rhs: CategoryArticleUUID) -> Bool {
        return lhs.uuidString == rhs.uuidString
    }
}
