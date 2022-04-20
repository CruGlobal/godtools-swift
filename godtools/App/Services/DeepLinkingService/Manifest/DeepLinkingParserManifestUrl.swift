//
//  DeepLinkingParserManifestUrl.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class DeepLinkingParserManifestUrl: DeepLinkingParserManifestType {
    
    let scheme: String
    let host: String
    let rootPathComponent: String?
    let parserClass: DeepLinkParserType.Type
    
    required init(scheme: String, host: String, rootPathComponent: String?, parserClass: DeepLinkParserType.Type) {
        
        self.scheme = scheme
        self.host = host
        self.rootPathComponent = rootPathComponent
        self.parserClass = parserClass
    }
    
    func matchesIncomingDeepLink(incomingDeepLink: IncomingDeepLinkType) -> Bool {
        
        switch incomingDeepLink {
        
        case .url(let incomingUrl):
            
            guard scheme == incomingUrl.url.scheme else {
                return false
            }
            
            guard host == incomingUrl.url.host else {
                return false
            }
            
            if let rootPathComponent = self.rootPathComponent, rootPathComponent != incomingUrl.rootPath {
                return false
            }
            
            return true
            
        default:
            return false
        }
    }
}
