//
//  DeepLinkingParserManifestUrl.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class DeepLinkingParserManifestUrl {
    
    let scheme: String
    let host: String
    let rootPathComponent: String?
    
    required init(scheme: String, host: String, rootPathComponent: String?) {
        
        self.scheme = scheme
        self.host = host
        self.rootPathComponent = rootPathComponent
    }
    
    func matchesIncomingUrl(incomingUrl: IncomingDeepLinkUrl) -> Bool {
        
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
    }
}
