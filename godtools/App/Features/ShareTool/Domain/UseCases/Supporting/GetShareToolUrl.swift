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

    func getUrl(toolId: String, toolLanguageId: String, pageNumber: Int, subPageNumber: Int?) -> String? {

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
        
        switch resource.resourceTypeEnum {
        
        case .chooseYourOwnAdventure:
            
            if pageNumber == 0 {
                toolUrl = toolUrl.appending(path: "intro")
            }
            else if pageNumber == 1 {
                toolUrl = toolUrl.appending(path: "categories")
            }
            else if let subPageNumber = subPageNumber {
                appendPageNumber(url: &toolUrl, pageNumber: subPageNumber, excludeIfPageIsZero: false)
            }
        
        default:
            appendPageNumber(url: &toolUrl, pageNumber: pageNumber, excludeIfPageIsZero: true)
            addGtShareQueryItem(url: &toolUrl)
        }
        
        let toolUrlString = toolUrl.absoluteString

        return toolUrlString
    }
    
    private func appendPageNumber(url: inout URL, pageNumber: Int, excludeIfPageIsZero: Bool) {
        
        if excludeIfPageIsZero && pageNumber == 0 {
            return
        }
        
        url = url.appending(path: String(pageNumber))
    }
    
    private func addGtShareQueryItem(url: inout URL) {
        
        let shareCampaignQueryItem: URLQueryItem = URLQueryItem(name: "icid", value: "gtshare")

        url = url.appending(queryItems: [shareCampaignQueryItem])
    }
}
