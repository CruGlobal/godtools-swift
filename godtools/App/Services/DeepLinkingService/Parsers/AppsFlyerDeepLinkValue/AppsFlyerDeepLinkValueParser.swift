//
//  AppsFlyerDeepLinkValueParser.swift
//  godtools
//
//  Created by Levi Eggert on 3/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AppsFlyerDeepLinkValueParser: DeepLinkParserType {
    
    func parse(incomingDeepLink: IncomingDeepLinkType) -> ParsedDeepLinkType? {
                
        switch incomingDeepLink {
        
        case .appsFlyer(let data):
            return parseDeepLinkFromAppsFlyer(data: data)
        
        default:
            return nil
        }
    }
    
    private func parseDeepLinkFromAppsFlyer(data: [AnyHashable: Any]) -> ParsedDeepLinkType? {
         
        guard let deepLinkValue = data["deep_link_value"] as? String else {
            return nil
        }
        
        let deepLinkValueComponents: [String] = deepLinkValue.components(separatedBy: "|")
        
        guard let rootComponent = deepLinkValueComponents[safe: 0] else {
            return nil
        }
        
        guard let locationComponent = deepLinkValueComponents[safe: 1] else {
            return nil
        }
        
        switch rootComponent {
        case "dashboard":

            switch locationComponent {
            case "tools":
                return .allToolsList
            case "home":
                return .favoritedToolsList
            case "lessons":
                return .lessonsList
            default:
                return nil
            }
            
        case "tool":
            
            guard let resourceAbbreviation = deepLinkValueComponents[safe: 2] else {
                return nil
            }
            
            guard let language = deepLinkValueComponents[safe: 3] else {
                return nil
            }
                                    
            switch locationComponent {
            case "tract":
                break
                
            case "lesson":
                break
                
            case "cyoa":
                break
                                
            case "article":
                break
                
            default:
                return nil
            }
            
            return .tool(
                toolDeepLink: ToolDeepLink(
                    resourceAbbreviation: resourceAbbreviation,
                    primaryLanguageCodes: [language],
                    parallelLanguageCodes: [],
                    liveShareStream: nil,
                    page: nil,
                    pageId: nil
                )
            )
            
        default:
            return nil
        }        
    }
}
