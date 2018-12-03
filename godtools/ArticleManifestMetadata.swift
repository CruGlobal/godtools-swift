//
//  ArticleManifestJSON.swift
//  godtools
//
//  Created by Igor Ostriz on 30/11/2018.
//  Copyright © 2018 Cru. All rights reserved.
//

import UIKit

class ArticleManifestMetadata: GodToolsJSONResource {

    var master = ""
    
    override func type() -> String {
        return "article-manifest"
    }
}
