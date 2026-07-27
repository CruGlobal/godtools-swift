//
//  ArticleDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ArticleDomainModel: Sendable, Identifiable {
    
    let id: String
    let title: String
    let httpsUrl: ArticleUrlDomainModel?
    let archiveUrl: ArticleUrlDomainModel?
    let isShareable: Bool
    let errorMessage: String?
}
