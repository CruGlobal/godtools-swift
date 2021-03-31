//
//  URLDeepLinkParser.swift
//  godtools
//
//  Created by Robert Eldredge on 3/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class URLDeepLinkParser: DeepLinkParserType {
    
    required init() {
        
    }
    
    func parse(incomingDeepLink: IncomingDeepLinkType) -> ParsedDeepLinkType? {
        switch incomingDeepLink {
        
        case .firebaseMessage(let url):
            return .url(url: url)
            
        default:
            return nil
        }
    }
}
