//
//  GetShareToolUrl.swift
//  godtools
//
//  Created by Levi Eggert on 3/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetShareToolUrl {
    
    enum ShareToolURLPath: String {
        case tract = "tool/v1"
        case cyoa = "tool/v2"
        case lesson = "lesson"
        
        init(resourceType: ResourceType) {
            switch resourceType {
            case .chooseYourOwnAdventure:
                self = .cyoa
            case .lesson:
                self = .lesson
            default:
                self = .tract
            }
        }
    }
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
        
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
    }
    
    func getUrl(toolId: String, toolLanguageId: String, pageNumber: Int) -> String? {
                
        let resourceType = resourcesRepository.persistence.getDataModelNonThrowing(id: toolId)?.resourceTypeEnum ?? .unknown

        guard let resource = resourcesRepository.persistence.getDataModelNonThrowing(id: toolId),
              let toolLanguage = languagesRepository.persistence.getDataModelNonThrowing(id: toolLanguageId) else {
            
            return nil
        }
        
        let path = ShareToolURLPath(resourceType: resourceType)
        
        var toolUrl: String = "https://knowgod.com/\(toolLanguage.code)/\(path.rawValue)/\(resource.abbreviation)"

        if pageNumber > 0 {
            toolUrl = toolUrl.appending("/").appending("\(pageNumber)")
        }
        
        toolUrl = toolUrl.replacingOccurrences(of: " ", with: "").appending("?icid=gtshare ")
                
        return toolUrl
    }
}
