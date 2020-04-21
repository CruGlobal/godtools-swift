//
//  ArticleResource.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ArticleResource: Decodable {
    
    let filename: String
    let src: String
    
    enum CodingKeys: String, CodingKey {
        case filename = "filename"
        case src = "src"
    }
}
