//
//  ArticleJcrContent.swift
//  godtools
//
//  Created by Levi Eggert on 4/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ArticleJcrContent: ArticleJcrContentType {
    
    let canonical: String?
    let tags: [String]
    let title: String?
    let uuid: String?
}
