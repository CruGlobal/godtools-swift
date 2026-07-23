//
//  ArticlesDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct ArticlesDomainModel: Sendable {
    
    let articleListItems: [ArticleListItemDomainModel]
    let error: ArticlesErrorDomainModel?
}
