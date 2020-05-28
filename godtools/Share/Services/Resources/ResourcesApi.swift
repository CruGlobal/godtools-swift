//
//  ResourcesApi.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourcesApi: ResourcesApiType {
    
    private let session: URLSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let baseUrl: String
    
    required init(config: ConfigType) {
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        configuration.urlCache = nil
        
        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.never
        configuration.httpShouldSetCookies = false
        configuration.httpCookieStorage = nil
        
        configuration.timeoutIntervalForRequest = 60
            
        session = URLSession(configuration: configuration)
        
        baseUrl = config.mobileContentApiBaseUrl
    }
    
    private func newResourcesPlusLatestTranslationsAndAttachmentsOperation() -> RequestOperation {
        
        let urlRequest: URLRequest = requestBuilder.build(
            session: session,
            urlString: baseUrl + "/resources?include=latest-translations,attachments",
            method: .get,
            headers: nil,
            httpBody: nil
        )
        
        return RequestOperation(session: session, urlRequest: urlRequest)
    }
    
    private func newLanguagesOperation() -> RequestOperation {
        
        let urlRequest: URLRequest = requestBuilder.build(
            session: session,
            urlString: baseUrl + "/languages",
            method: .get,
            headers: nil,
            httpBody: nil
        )
        
        return RequestOperation(session: session, urlRequest: urlRequest)
    }
    
    func getResourcesJson(complete: @escaping ((_ result: Result<ResourcesJson, ResourcesApiError>) -> Void)) -> OperationQueue {
        
        let queue = OperationQueue()
        
        let resourcesOperation: RequestOperation = newResourcesPlusLatestTranslationsAndAttachmentsOperation()
        let languagesOperation: RequestOperation = newLanguagesOperation()
            
        var resourcesResponse: RequestResponse?
        var languagesResponse: RequestResponse?
        
        resourcesOperation.completionHandler { [weak self] (response: RequestResponse) in
            
            resourcesResponse = response
            
            if let languagesResponse = languagesResponse {
                self?.handleGetResourcesJsonComplete(resourcesResponse: response, languagesResponse: languagesResponse, complete: complete)
            }
        }
        
        languagesOperation.completionHandler { [weak self] (response: RequestResponse) in
            
            languagesResponse = response
            
            if let resourcesResponse = resourcesResponse {
                self?.handleGetResourcesJsonComplete(resourcesResponse: resourcesResponse, languagesResponse: response, complete: complete)
            }
        }
        
        queue.addOperations(
            [resourcesOperation, languagesOperation],
            waitUntilFinished: false
        )
        
        return queue
    }
    
    private func handleGetResourcesJsonComplete(resourcesResponse: RequestResponse, languagesResponse: RequestResponse, complete: @escaping ((_ result: Result<ResourcesJson, ResourcesApiError>) -> Void)) {
        
        let error: Error? = resourcesResponse.error ?? languagesResponse.error
        
        if let error = error {
            
            let resourcesApiError: ResourcesApiError
            
            if error.notConnectedToInternet {
                resourcesApiError = .noNetworkConnection
            }
            else if error.isCancelled {
                resourcesApiError = .cancelled
            }
            else {
                resourcesApiError = .unknownError(error: error)
            }
            
            complete(.failure(resourcesApiError))
        }
        else {
            
            let resourcesJson = ResourcesJson(
                resourcesPlusLatestTranslationsAndAttachmentsJson: resourcesResponse.data,
                languagesJson: languagesResponse.data
            )
            complete(.success(resourcesJson))
        }
    }
}
