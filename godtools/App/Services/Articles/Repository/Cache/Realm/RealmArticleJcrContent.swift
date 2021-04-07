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
    
    @objc dynamic var aemUri: String = ""
    @objc dynamic var canonical: String?
    @objc dynamic var title: String?
    @objc dynamic var uuid: String?
    
    let tags = List<String>()
    
    func mapFrom(model: ArticleJcrContent) {
        
        aemUri = model.aemUri
        canonical = model.canonical
        title = model.title
        uuid = model.uuid
        tags.removeAll()
        tags.append(objectsIn: model.tags)
    }
}
