//
//  ArticleAemRepository.swift
//  godtools
//
//  Created by Robert Eldredge on 3/1/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ArticleAemRepository: NSObject, ArticleAemRepositoryType {
    
    let downloader: ArticleAemDownloader
    let cache: ArticleAemCache
    
    init(downloader: ArticleAemDownloader, cache: ArticleAemCache) {
        
        self.downloader = downloader
        self.cache = cache
        
        super.init()
    }
}
