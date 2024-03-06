//
//  TractRemoteShareURLBuilder.swift
//  godtools
//
//  Created by Levi Eggert on 8/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

// Example url: https: //knowgod.com/de/kgp?icid=gtshare&primaryLanguage=en&parallelLanguage=de&liveShareStream=9cae02af93e1d510c3e0-1597355635

class TractRemoteShareURLBuilder {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
    }
    
    func buildRemoteShareURL(toolId: String, primaryLanguageId: String, parallelLanguageId: String?, selectedLanguageId: String, page: Int?, subscriberChannelId: String) -> String? {
                
        let resource: ResourceModel? = resourcesRepository.getResource(id: toolId)
        let selectedLanguage: LanguageModel? = languagesRepository.getLanguage(id: selectedLanguageId)
        
        var urlPath: String = ""
        
        if let languageCode = selectedLanguage?.code {
            urlPath += "/" + languageCode
        }
        
        if let abbreviation = resource?.abbreviation {
            urlPath += "/" + abbreviation
        }
        
        if let page = page {
            urlPath += "/" + String(page)
        }
        
        var urlComponents: URLComponents = URLComponents()
        
        urlComponents.scheme = "https"
        urlComponents.host = "knowgod.com"
        urlComponents.path = urlPath
        
        var queryItems: [URLQueryItem] = Array()
        
        if let parallelLanguageId = parallelLanguageId, let parallelLanguage = languagesRepository.getLanguage(id: parallelLanguageId) {
            queryItems.append(URLQueryItem(name: "parallelLanguage", value: parallelLanguage.code))
        }
        
        queryItems.append(URLQueryItem(name: "icid", value: "gtshare"))
        
        if let primaryLanguage = languagesRepository.getLanguage(id: primaryLanguageId) {
            queryItems.append(URLQueryItem(name: "primaryLanguage", value: primaryLanguage.code))
        }
        
        queryItems.append(URLQueryItem(name: "liveShareStream", value: subscriberChannelId))
        
        urlComponents.queryItems = queryItems
        
        let urlString: String? = urlComponents.url?.absoluteString
        
        return urlString
    }
}
