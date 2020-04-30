//
//  RealmArticleJcrContent.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmArticleJcrContent: Object, ArticleJcrContentType {
    
    @objc dynamic var canonical: String?
    let tags = List<String>()
    @objc dynamic var title: String?
    @objc dynamic var uuid: String?
    
    required init(canonical: String?, title: String?, uuid: String?, tags: [String]) {
        self.canonical = canonical
        self.title = title
        self.uuid = uuid
        self.tags.append(objectsIn: tags)
    }
    
    required init() {
        
    }
}
