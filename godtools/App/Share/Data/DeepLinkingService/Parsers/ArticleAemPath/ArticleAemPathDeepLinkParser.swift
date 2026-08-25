//
//  ArticleAemPathDeepLinkParser.swift
//  godtools
//
//  Created by Levi Eggert on 2/22/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class ArticleAemPathDeepLinkParser: DeepLinkUrlParserInterface {
    
    required init() {
        
    }
    
    func parse(url: URL, pathComponents: [String], queryParameters: [String: Any]) -> ParsedDeepLinkType? {
                      
        guard let aemUri = queryParameters["uri"] as? String else {
            return nil
        }
        
        return .articleAemUri(aemUri: aemUri)
    }
}
