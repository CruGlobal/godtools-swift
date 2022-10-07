//
//  ArticleDeepLinkParser.swift
//  godtools
//
//  Created by Robert Eldredge on 2/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ArticleDeepLinkParser: DeepLinkUrlParserType {
    
    required init() {
        
    }
    
    func parse(pathComponents: [String], queryParameters: [String : Any]) -> ParsedDeepLinkType? {
        
        guard pathComponents[safe: 1] == "aem" else {
            return nil
        }
                        
        guard let articleUri = queryParameters["uri"] as? String else {
            return nil
        }
        
        return .article(articleURI: articleUri)
    }
}
