//
//  ArticleAemUri.swift
//  godtools
//
//  Created by Levi Eggert on 3/1/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ArticleAemUri {
    
    let uriString: String
    let url: URL?
    
    required init(aemUri: String) {
        
        self.uriString = aemUri
        self.url = URL(string: aemUri)
    }
}
