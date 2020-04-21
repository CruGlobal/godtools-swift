//
//  ArticleCategory.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ArticleCategory: Decodable {
    
    let bannerFilename: String
    let bannerSrc: String
    let id: String
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case bannerFilename = "banner_filename"
        case bannerSrc = "banner_src"
        case id = "id"
        case title = "title"
    }
}
