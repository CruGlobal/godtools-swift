//
//  GetResourcesAndLanguagesData.swift
//  godtools
//
//  Created by Levi Eggert on 8/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetResourcesAndLanguagesData {

    static func parseResourcePlusLatestTranslationsAndAttachmentsModel(resourcesData: Data) -> AnyPublisher<ResourcesPlusLatestTranslationsAndAttachmentsModel, Error> {
                
        do {
            
            let resources: ResourcesPlusLatestTranslationsAndAttachmentsModel = try JSONDecoder().decode(ResourcesPlusLatestTranslationsAndAttachmentsModel.self, from: resourcesData)
            
            return Just(resources).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        catch let error {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    static func getResourcesPlusLatestTranslationsAndAttachmentsPlusLanguagesData(session: URLSession, apiBaseUrl: String) -> AnyPublisher<(resourcesData: Data, languagesData: Data), Error> {
        
        return Publishers
            .CombineLatest(getResourcesPlusLatestTranslationsAndAttachments(session: session, apiBaseUrl: apiBaseUrl), getLanguages(session: session, apiBaseUrl: apiBaseUrl))
            .mapError {
                return $0 as Error
            }
            .flatMap({ (resources: (data: Data, response: URLResponse), languages: (data: Data, response: URLResponse)) -> AnyPublisher<(resourcesData: Data, languagesData: Data), Error> in
                
                let resourcesHttpStatusCode: Int = (resources.response as? HTTPURLResponse)?.statusCode ?? -1
                let languagesHttpStatusCode: Int = (languages.response as? HTTPURLResponse)?.statusCode ?? -1
                
                guard (resourcesHttpStatusCode >= 200 && resourcesHttpStatusCode < 400) && (languagesHttpStatusCode >= 200 && languagesHttpStatusCode < 400) else {
                    
                    return Fail(error: NSError.errorWithDescription(description: "Failed to fetch resources.  Invalid httpStatusCode."))
                        .eraseToAnyPublisher()
                }
                
                return Just((resourcesData: resources.data, languagesData: languages.data))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private static func getResourcesPlusLatestTranslationsAndAttachments(session: URLSession, apiBaseUrl: String) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        
        let urlString: String = apiBaseUrl + "/resources?filter[system]=GodTools&include=latest-translations,attachments"
        
        guard let url = URL(string: urlString) else {
            
            let description: String = "Failed to create url from urlString: \(urlString)"
            let error: URLError = URLError(URLError.Code(rawValue: -1), userInfo: [NSLocalizedDescriptionKey: description])
            
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        let configuration = session.configuration
        
        var urlRequest = URLRequest(
            url: url,
            cachePolicy: configuration.requestCachePolicy,
            timeoutInterval: configuration.timeoutIntervalForRequest
        )

        urlRequest.httpMethod = "GET"
        
        return session.dataTaskPublisher(for: urlRequest)
            .eraseToAnyPublisher()
    }
    
    private static func getLanguages(session: URLSession, apiBaseUrl: String) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        
        let urlString: String = apiBaseUrl + "/languages"
        
        guard let url = URL(string: urlString) else {
            
            let description: String = "Failed to create url from urlString: \(urlString)"
            let error: URLError = URLError(URLError.Code(rawValue: -1), userInfo: [NSLocalizedDescriptionKey: description])
            
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        let configuration = session.configuration
        
        var urlRequest = URLRequest(
            url: url,
            cachePolicy: configuration.requestCachePolicy,
            timeoutInterval: configuration.timeoutIntervalForRequest
        )

        urlRequest.httpMethod = "GET"
        
        return session.dataTaskPublisher(for: urlRequest)
            .eraseToAnyPublisher()
    }
}
