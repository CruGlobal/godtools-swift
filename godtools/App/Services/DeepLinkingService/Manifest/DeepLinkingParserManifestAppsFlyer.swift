//
//  DeepLinkingParserManifestAppsFlyer.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class DeepLinkingParserManifestAppsFlyer: DeepLinkingParserManifestType {
    
    let parserClass: DeepLinkParserType.Type
    
    required init(parserClass: DeepLinkParserType.Type) {
        
        self.parserClass = parserClass
    }
    
    func matchesIncomingDeepLink(incomingDeepLink: IncomingDeepLinkType) -> Bool {
        
        return true
    }
}
