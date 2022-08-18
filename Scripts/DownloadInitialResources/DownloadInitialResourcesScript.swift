//
//  DownloadInitialResourcesScript.swift
//  godtools
//
//  Created by Levi Eggert on 8/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

@main
enum DownloadInitialResourcesScript {
             
    static func main() {
        
        print("Hello DownloadInitialResourcesScript")
        
        let session: URLSession = DownloadInitialResourcesScript.getSession()
        let apiBaseUrl: String = "https://mobile-content-api.cru.org"
        
        
        let semaphore = DispatchSemaphore( value: 0)
        let getResourcesCancellable: AnyCancellable? = DownloadInitialResourcesScript.getResourcesPlusLatestTranslationsAndAttachmentsPlusLanguagesData(session: session, apiBaseUrl: apiBaseUrl)
            .sink { _ in
                
            } receiveValue: { (resources: Data, languages: Data) in
                
            }
    }
    
    private static func getSession() -> URLSession {
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        configuration.urlCache = nil
        
        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.never
        configuration.httpShouldSetCookies = false
        configuration.httpCookieStorage = nil
        
        configuration.timeoutIntervalForRequest = 60
     
        return URLSession(configuration: configuration)
    }
    
    private static func getResourcesPlusLatestTranslationsAndAttachmentsPlusLanguagesData(session: URLSession, apiBaseUrl: String) -> AnyPublisher<(resources: Data, languages: Data), Error> {
        
        return Publishers
            .CombineLatest(getResourcesPlusLatestTranslationsAndAttachments(session: session, apiBaseUrl: apiBaseUrl), getLanguages(session: session, apiBaseUrl: apiBaseUrl))
            .mapError {
                return $0 as Error
            }
            .flatMap({ (resources: (data: Data, response: URLResponse), languages: (data: Data, response: URLResponse)) -> AnyPublisher<(resources: Data, languages: Data), Error> in
                
                let resourcesHttpStatusCode: Int = (resources.response as? HTTPURLResponse)?.statusCode ?? -1
                let languagesHttpStatusCode: Int = (languages.response as? HTTPURLResponse)?.statusCode ?? -1
                
                guard (resourcesHttpStatusCode >= 200 && resourcesHttpStatusCode < 400) && (languagesHttpStatusCode >= 200 && languagesHttpStatusCode < 400) else {
                    
                    let description: String = "Failed to fetch resources.  Invalid httpStatusCode."
                    let error: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: description])
                    
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
                
                return Just((resources: resources.data, languages: languages.data))
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
