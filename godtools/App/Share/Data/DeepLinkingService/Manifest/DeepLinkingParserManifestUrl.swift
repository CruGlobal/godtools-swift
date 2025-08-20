//
//  DeepLinkingParserManifestUrl.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class DeepLinkingParserManifestUrl: DeepLinkingParserManifestInterface {
    
    let scheme: String
    let hosts: [String]
    let path: String?
    let parserClass: DeepLinkParserInterface.Type
    
    init(scheme: String, hosts: [String], path: String?, parserClass: DeepLinkParserInterface.Type) {
        
        self.scheme = scheme
        self.hosts = hosts
        self.path = path
        self.parserClass = parserClass
    }
    
    func getParserIfValidIncomingDeepLink(incomingDeepLink: IncomingDeepLinkType) -> DeepLinkParserInterface? {
        
        switch incomingDeepLink {
        
        case .url(let incomingUrl):
            
            let schemeOrHostIsEmpty: Bool = scheme.isEmpty || hosts.isEmpty
            
            guard !schemeOrHostIsEmpty else {
                return nil
            }
            
            guard scheme == incomingUrl.url.scheme else {
                return nil
            }
            
            guard let incomingUrlHost = incomingUrl.url.host, hosts.contains(incomingUrlHost) else {
                return nil
            }
            
            guard isValidPath(incomingUrl: incomingUrl) else {
                return nil
            }
            
            return parserClass.init()
        }
    }
    
    private func isValidPath(incomingUrl: IncomingDeepLinkUrl) -> Bool {
        
        guard let path = self.path else {
            return true
        }
        
        let incomingUrlRootPath: String? = incomingUrl.rootPath
        let incomingUrlRootPathIsEmpty: Bool
        
        if let incomingUrlRootPath = incomingUrlRootPath {
            incomingUrlRootPathIsEmpty = incomingUrlRootPath.isEmpty
        }
        else {
            incomingUrlRootPathIsEmpty = true
        }
        
        if path.isEmpty && incomingUrlRootPathIsEmpty {
            return true
        }
        else if path.isEmpty && !incomingUrlRootPathIsEmpty {
            return false
        }
        
        let pathComponents: [String] = path.components(separatedBy: "/").filter({$0 != "/"})
        let incomingPathComponents: [String] = incomingUrl.pathComponents.filter({$0 != "/"})
        
        let pathComponentsIsLessThanOrEqualToIncomingPathComponents: Bool = pathComponents.count <= incomingPathComponents.count
        
        guard pathComponentsIsLessThanOrEqualToIncomingPathComponents else {
            return false
        }
        
        let incomingPathComponentsMatchingPathComponentsLength = Array(incomingPathComponents.prefix(pathComponents.count))
        
        guard pathComponents == incomingPathComponentsMatchingPathComponentsLength else {
            return false
        }
        
        return true
    }
}
