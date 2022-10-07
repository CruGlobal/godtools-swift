//
//  AppsFlyerDeepLinkValueParser.swift
//  godtools
//
//  Created by Levi Eggert on 3/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AppsFlyerDeepLinkValueParser: DeepLinkAppsFlyerParserType {
    
    private let appsFlyerComponentsParser: AppsFlyerDeepLinkValueComponentsParser = AppsFlyerDeepLinkValueComponentsParser()
    
    required init() {
        
    }
    
    func parse(data: [AnyHashable : Any]) -> ParsedDeepLinkType? {
        
        guard let deepLinkValue = data["deep_link_value"] as? String else {
            return nil
        }
        
        let deepLinkValueComponents: [String] = deepLinkValue.components(separatedBy: "|")
                
        return appsFlyerComponentsParser.getParsedDeepLink(components: deepLinkValueComponents)
    }
}
