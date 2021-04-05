//
//  ArticleJcrContent.swift
//  godtools
//
//  Created by Levi Eggert on 4/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ArticleJcrContent: ArticleJcrContentType {
    
    let aemUri: String
    let canonical: String?
    let tags: [String]
    let title: String?
    let uuid: String?
    
    init(aemUri: String, canonical: String?, tags: [String], title: String?, uuid: String?) {
        
        self.aemUri = aemUri
        self.canonical = canonical
        self.tags = tags
        self.title = title
        self.uuid = uuid
    }
    
    init(realmModel: RealmArticleJcrContent) {
        
        aemUri = realmModel.aemUri
        canonical = realmModel.canonical
        tags = Array(realmModel.tags)
        title = realmModel.title
        uuid = realmModel.uuid
    }
}
