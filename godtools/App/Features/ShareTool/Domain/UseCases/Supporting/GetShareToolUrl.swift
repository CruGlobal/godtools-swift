//
//  GetShareToolUrl.swift
//  godtools
//
//  Created by Levi Eggert on 3/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetShareToolUrl: Sendable {
    
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

        let baseUrl: URL? = URL(string: "https://knowgod.com")
        
        guard let baseUrl = baseUrl,
              let resource = resourcesRepository.getResourceById(id: toolId),
              let toolLanguage = languagesRepository.getLanguageById(id: toolLanguageId) else {

            return nil
        }

        let path = ShareToolURLPath(resourceType: resource.resourceTypeEnum)

        var toolUrl: URL = baseUrl
            .appending(path: toolLanguage.code)
            .appending(path: path.rawValue)
            .appending(path: resource.abbreviation)

        if pageNumber > 0 {
            toolUrl = toolUrl.appending(path: String(pageNumber))
        }
        
        let shareCampaignQueryItem: URLQueryItem = URLQueryItem(name: "icid", value: "gtshare")

        toolUrl = toolUrl.appending(queryItems: [shareCampaignQueryItem])

        return toolUrl.absoluteString
    }
}
