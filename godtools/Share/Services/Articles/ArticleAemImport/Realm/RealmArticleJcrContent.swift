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
}
