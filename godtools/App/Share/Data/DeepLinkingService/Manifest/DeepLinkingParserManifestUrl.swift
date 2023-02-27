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
    let path: String?
    let parserClass: DeepLinkParserType.Type
    
    init(scheme: String, host: String, path: String?, parserClass: DeepLinkParserType.Type) {
        
        self.scheme = scheme
        self.host = host
        self.path = path
        self.parserClass = parserClass
    }
    
    func getParserIfValidIncomingDeepLink(incomingDeepLink: IncomingDeepLinkType) -> DeepLinkParserType? {
        
        switch incomingDeepLink {
        
        case .url(let incomingUrl):
            
            guard scheme == incomingUrl.url.scheme else {
                return nil
            }
            
            guard host == incomingUrl.url.host else {
                return nil
            }
            
            guard isValidPath(incomingUrl: incomingUrl) else {
                return nil
            }
            
            return parserClass.init()
            
        default:
            return nil
        }
    }
    
    private func isValidPath(incomingUrl: IncomingDeepLinkUrl) -> Bool {
        
        let path: String = self.path ?? ""
        
        guard !path.isEmpty else {
            return true
        }
        
        let pathComponents: [String] = path.components(separatedBy: "/").filter({$0 != "/"})
        
        guard !pathComponents.isEmpty else {
            return true
        }
        
        let incomingPathComponents: [String] = incomingUrl.pathComponents.filter({$0 != "/"})
        
        guard pathComponents.count <= incomingPathComponents.count else {
            return false
        }
        
        let incomingPathComponentsMatchingPathComponentsLength = Array(incomingPathComponents.prefix(pathComponents.count))
        
        guard pathComponents == incomingPathComponentsMatchingPathComponentsLength else {
            return false
        }
        
        return true
    }
}
