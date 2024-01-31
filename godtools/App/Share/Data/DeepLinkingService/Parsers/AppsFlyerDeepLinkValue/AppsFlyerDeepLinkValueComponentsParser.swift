//
//  AppsFlyerDeepLinkValueComponentsParser.swift
//  godtools
//
//  Created by Levi Eggert on 3/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AppsFlyerDeepLinkValueComponentsParser {
    
    func getParsedDeepLink(components: [String]) -> ParsedDeepLinkType? {
        
        guard let rootComponent = components[safe: 0] else {
            return nil
        }
        
        guard let locationComponent = components[safe: 1] else {
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
            
            guard let resourceAbbreviation = components[safe: 2] else {
                return nil
            }
            
            guard let language = components[safe: 3] else {
                return nil
            }
            
            var pageNumber: Int?
            var pageId: String?
                                    
            switch locationComponent {
            case "tract":
                if let pageStringValue = components[safe: 3], let pageIntValue = Int(pageStringValue) {
                    pageNumber = pageIntValue
                }
                
            case "lesson":
                break
                
            case "cyoa":
                if let pageIdValue = components[safe: 3] {
                    pageId = pageIdValue
                }
                                
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
                    page: pageNumber,
                    pageId: pageId,
                    selectedLanguageIndex: nil
                )
            )
            
        default:
            return nil
        }
    }
}
