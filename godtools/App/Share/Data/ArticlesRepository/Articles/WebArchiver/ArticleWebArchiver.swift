//
//  ArticleWebArchiver.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation
import Fuzi

class ArticleWebArchiver {
    
    private let priorityRequestSender: PriorityRequestSenderInterface
    private let ignoreCacheSession: IgnoreCacheSession
    private let includeJavascript: Bool = true
    private let errorDomain: String = "ArticleWebArchiver"
        
    init(priorityRequestSender: PriorityRequestSenderInterface, ignoreCacheSession: IgnoreCacheSession) {
        
        self.priorityRequestSender = priorityRequestSender
        self.ignoreCacheSession = ignoreCacheSession
    }
    
    func archivePublisher(webArchiveUrls: [WebArchiveUrl], sendRequestPriority: SendRequestPriority) -> AnyPublisher<ArticleWebArchiverResult, Never> {
        
        let urlSession: URLSession = ignoreCacheSession.session
        
        let requestSender: RequestSender = priorityRequestSender.createRequestSender(sendRequestPriority: sendRequestPriority)
        
        let requests: [AnyPublisher<ArticleWebArchiveResult, Never>] = webArchiveUrls.map { (webArchiveUrl: WebArchiveUrl) in
            
            return self.archiveUrlPublisher(
                webArchiveUrl: webArchiveUrl,
                urlSession: urlSession,
                requestSender: requestSender
            )
        }
        
        return Publishers.MergeMany(requests)
            .collect()
            .map { (results: [ArticleWebArchiveResult]) in
                
                return ArticleWebArchiverResult(
                    successfulArchives: results.compactMap { $0.data },
                    failedArchives: results.compactMap { $0.error },
                    totalAttemptedArchives: requests.count
                )
            }
            .eraseToAnyPublisher()
    }
    
    private func archiveUrlPublisher(webArchiveUrl: WebArchiveUrl, urlSession: URLSession, requestSender: RequestSender) -> AnyPublisher<ArticleWebArchiveResult, Never> {
        
        return requestHtmlDocumentDataPublisher(
            url: webArchiveUrl.webUrl,
            includeJavascript: includeJavascript,
            urlSession: urlSession,
            requestSender: requestSender
        )
        .flatMap { (htmlDocumentDataResult: ArchiveHtmlDocumentDataResult) -> AnyPublisher<ArticleWebArchiveResult, Never> in
            
            guard let data = htmlDocumentDataResult.data else {
                return Just(ArticleWebArchiveResult(data: nil, error: nil))
                    .eraseToAnyPublisher()
            }
            
            return self.requestHtmlDocumentResourcesPublisher(
                resourceUrls: data.resourceUrls,
                urlSession: urlSession,
                requestSender: requestSender
            )
            .map { (resources: [WebArchiveResource]) in
                
                let webArchive = WebArchive(
                    mainResource: data.mainResource,
                    webSubresources: resources
                )
                
                let plistEncoder = PropertyListEncoder()
                plistEncoder.outputFormat = .binary
                
                do {
                    
                    let plistData: Data = try plistEncoder.encode(webArchive)
                    let archiveData = ArticleWebArchiveData(webArchiveUrl: webArchiveUrl, webArchivePlistData: plistData)
                    let webArchiveResult = ArticleWebArchiveResult(data: archiveData, error: nil)

                    return webArchiveResult
                }
                catch let encodePlistDataError {
                    
                    let archiveError: WebArchiveOperationError = .failedEncodingPlistData(error: encodePlistDataError)
                    
                    return ArticleWebArchiveResult(data: nil, error: archiveError)
                }
            }
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    private func requestHtmlDocumentDataPublisher(url: URL, includeJavascript: Bool, urlSession: URLSession, requestSender: RequestSender) -> AnyPublisher<ArchiveHtmlDocumentDataResult, Never> {
        
        guard let host = url.host else {
            
            let error: Error = NSError(
                domain: errorDomain,
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid url host."
            ])
            
            let archiveError: WebArchiveOperationError = .invalidHost(error: error)
            
            return Just(ArchiveHtmlDocumentDataResult(data: nil, error: archiveError))
                .eraseToAnyPublisher()
        }
        
        let errorDomain: String = self.errorDomain
        
        let urlRequest: URLRequest = URLRequest(url: url)
                       
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest, urlSession: urlSession)
            .flatMap { (response: RequestDataResponse) -> AnyPublisher<ArchiveHtmlDocumentDataResult, Never> in
                
                let httpStatusCode: Int = response.urlResponse.httpStatusCode ?? -1
                let isSuccessHttpStatusCode: Bool = httpStatusCode >= 200 && httpStatusCode < 400
                let mimeType: String = response.urlResponse.mimeType ?? ""
                   
                if !isSuccessHttpStatusCode {
                    
                    let error: Error = NSError(
                        domain: errorDomain,
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "The request failed with a status code: \(httpStatusCode)"
                    ])
                    
                    let archiveError: WebArchiveOperationError = .responseError(error: error)
                    
                    return Just(ArchiveHtmlDocumentDataResult(data: nil, error: archiveError))
                        .eraseToAnyPublisher()
                }
                else if mimeType != "text/html" {
                    
                    let error: Error = NSError(
                        domain: errorDomain,
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to archive url because the mimetype is not text/html. Found mimeType: \(mimeType)"
                    ])
                    
                    let archiveError: WebArchiveOperationError = .invalidMimeType(error: error)
                    
                    return Just(ArchiveHtmlDocumentDataResult(data: nil, error: archiveError))
                        .eraseToAnyPublisher()
                }
                else if let htmlString = String(data: response.data, encoding: .utf8) {
                    
                    do {
                       
                        let webArchiveResource: WebArchiveResource = WebArchiveResource(url: url, data: response.data, mimeType: mimeType)
                        let mainResource: WebArchiveMainResource = WebArchiveMainResource(baseResource: webArchiveResource)
                        
                        // NOTE: Using HTMLDocumentWrapper for now with open PR fix until merged and Fuzi is updated. ~Levi
                        // TODO: GT-2492 Remove HTMLDocumentWrapper once PR is merged. ~Levi
                        //let htmlDocument: HTMLDocument = try HTMLDocument(string: htmlString, encoding: .utf8)
                        let htmlDocument: HTMLDocument = try HTMLDocumentWrapper(string: htmlString, encoding: .utf8).htmlDocument
                        let resourceUrls: [String] = htmlDocument.getHTMLReferences(host: host, includeJavascript: includeJavascript)
                        let result = ArchiveHtmlDocumentDataResult(data: HTMLDocumentData(mainResource: mainResource, resourceUrls: resourceUrls), error: nil)
                        
                        return Just(result)
                            .eraseToAnyPublisher()
                    }
                    catch let parseHtmlDocumentError {
                        
                        let archiveError: WebArchiveOperationError = .failedToParseHtmlDocument(error: parseHtmlDocumentError)
                        
                        return Just(ArchiveHtmlDocumentDataResult(data: nil, error: archiveError))
                            .eraseToAnyPublisher()
                    }
                }
                else {
                    
                    let noHtmlData = NSError(
                        domain: errorDomain,
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to archive url there wasn't sufficent html to parse."
                    ])
                    
                    let archiveError: WebArchiveOperationError = .failedToParseHtmlDocument(error: noHtmlData)
                    
                    return Just(ArchiveHtmlDocumentDataResult(data: nil, error: archiveError))
                        .eraseToAnyPublisher()
                }
            }
            .catch { (error: Error) in
                
                let errorCode: Int = (error as NSError).code
                let operationError: WebArchiveOperationError
                
                if errorCode == CFNetworkErrors.cfurlErrorCancelled.rawValue {
                    operationError = .cancelled
                }
                else if errorCode == CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue {
                    operationError = .noNetworkConnection
                }
                else {
                    operationError = .unknownError(error: error)
                }
                
                return Just(ArchiveHtmlDocumentDataResult(data: nil, error: operationError))
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func requestHtmlDocumentResourcesPublisher(resourceUrls: [String], urlSession: URLSession, requestSender: RequestSender) -> AnyPublisher<[WebArchiveResource], Never> {
        
        let requests: [AnyPublisher<WebArchiveResource?, Never>] = resourceUrls.compactMap { (resourceUrlString: String) in
            
            guard let resourceUrl = URL(string: resourceUrlString) else {
                return Just(nil)
                    .eraseToAnyPublisher()
            }
            
            let urlRequest = URLRequest(url: resourceUrl)
            
            return requestSender.sendDataTaskPublisher(urlRequest: urlRequest, urlSession: urlSession)
                .map { (response: RequestDataResponse) in
                    
                    let httpStatusCode: Int = response.urlResponse.httpStatusCode ?? -1
                    let isSuccessHttpStatusCode: Bool = httpStatusCode >= 200 && httpStatusCode < 400
                    let mimeType: String = response.urlResponse.mimeType ?? ""
                    
                    if isSuccessHttpStatusCode, !mimeType.isEmpty {
                        
                        let webArchiveResource = WebArchiveResource(
                            url: resourceUrl,
                            data: response.data,
                            mimeType: mimeType
                        )
                        
                        return webArchiveResource
                    }
                    
                    return nil
                }
                .catch { (error: Error) in
                    return Just(nil)
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(requests)
            .collect()
            .map { (resources: [WebArchiveResource?]) in
                let nonNilResources: [WebArchiveResource] = resources.compactMap {
                    return $0
                }
                return nonNilResources
            }
            .eraseToAnyPublisher()
    }
}
