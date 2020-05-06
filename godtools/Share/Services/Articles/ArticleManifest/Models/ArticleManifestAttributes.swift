//
//  ArticleManifestAttributes.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ArticleManifestAttributes: Decodable {
    
    let categoryLabelRGBAColor: String? // ex: "rgba(255,255,255,1)"
    let locale: String?
    let tool: String?
    let type: String?
    
    enum CodingKeys: String, CodingKey {
        case categoryLabelRGBAColor = "category-label-color"
        case locale = "locale"
        case tool = "tool"
        case type = "type"
    }
}
