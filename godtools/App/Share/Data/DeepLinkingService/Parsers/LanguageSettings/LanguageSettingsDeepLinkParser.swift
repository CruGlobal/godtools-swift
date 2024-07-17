//
//  LanguageSettingsDeepLinkParser.swift
//  godtools
//
//  Created by Levi Eggert on 3/13/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class LanguageSettingsDeepLinkParser: DeepLinkUrlParserType {
    
    required init() {
        
    }
    
    func parse(url: URL, pathComponents: [String], queryParameters: [String : Any]) -> ParsedDeepLinkType? {
        
        return .languageSettings
    }
}
