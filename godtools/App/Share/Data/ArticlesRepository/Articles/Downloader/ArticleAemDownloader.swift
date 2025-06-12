//
//  ArticleAemDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

class ArticleAemDownloader {
            
    private let requestSender: RequestSender = RequestSender()
    private let urlSessionPriority: URLSessionPriority
    private let maxAemJsonTreeLevels: Int = 9999
        
    init(urlSessionPriority: URLSessionPriority) {
        
        self.urlSessionPriority = urlSessionPriority
    }
    
    func downloadPublisher(aemUris: [String], downloadCachePolicy: ArticleAemDownloaderCachePolicy, requestPriority: RequestPriority) -> AnyPublisher<ArticleAemDownloaderResult, Never> {
                
        let requests: [AnyPublisher<AemUriDownloadResult, Never>] = aemUris.map { (aemUri: String) in
            
            return self.downloadAemUriPublisher(
                aemUri: aemUri,
                downloadCachePolicy: downloadCachePolicy,
                requestPriority: requestPriority
            )
            .eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(requests)
            .collect()
            .map { (results: [AemUriDownloadResult]) in
                
                return ArticleAemDownloaderResult(
                    aemDataObjects: results.compactMap { $0.articleAemData },
                    aemDownloadErrors: results.compactMap { $0.downloadError }
                )
            }
            .eraseToAnyPublisher()
    }
    
    private func downloadAemUriPublisher(aemUri: String, downloadCachePolicy: ArticleAemDownloaderCachePolicy, requestPriority: RequestPriority) -> AnyPublisher<AemUriDownloadResult, Never> {
        
        guard let aemUrl = URL(string: aemUri) else {
            
            let error: ArticleAemDownloadOperationError = .invalidAemSrcUrl
            
            return Just(AemUriDownloadResult(articleAemData: nil, downloadError: error))
                .eraseToAnyPublisher()
        }
                
        let cacheTimeInterval: TimeInterval = downloadCachePolicy.getCacheTimeInterval()
        
        let urlJsonString: String = aemUri + "." + String(maxAemJsonTreeLevels) + ".json?_=\(cacheTimeInterval)"
        
        guard let urlJson: URL = URL(string: urlJsonString) else {
            
            let error: ArticleAemDownloadOperationError = .invalidAemJsonUrl
            
            return Just(AemUriDownloadResult(articleAemData: nil, downloadError: error))
                .eraseToAnyPublisher()
        }
        
        let errorDomain: String = "ArticleAemDownloadOperation"
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest = URLRequest(
            url: urlJson,
            cachePolicy: urlSession.configuration.requestCachePolicy,
            timeoutInterval: urlSession.configuration.timeoutIntervalForRequest
        )
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest, urlSession: urlSession)
            .flatMap { (response: RequestDataResponse) -> AnyPublisher<AemUriDownloadResult, Never> in
                
                let httpStatusCode: Int = response.urlResponse.httpStatusCode ?? -1
                let isSuccessHttpStatusCode: Bool = httpStatusCode >= 200 && httpStatusCode < 400
                
                if isSuccessHttpStatusCode {
                    
                    // validate json
                    var jsonDictionary: [String: Any] = Dictionary()
                    var jsonError: Error?
                    
                    do {
                        let json: Any = try JSONSerialization.jsonObject(with: response.data, options: [])
                        if let dictionary = json as? [String: Any] {
                            jsonDictionary = dictionary
                        }
                    }
                    catch let error {
                        jsonError = error
                    }
                    
                    if jsonDictionary.isEmpty, jsonError == nil {
                        
                        jsonError = NSError(
                            domain: errorDomain,
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Failed to parse jsonData because data does not exist."
                        ])
                    }
                    
                    if let jsonError = jsonError {
                        let error: ArticleAemDownloadOperationError = .failedToSerializeJson(error: jsonError)
                        return Just(AemUriDownloadResult(articleAemData: nil, downloadError: error))
                            .eraseToAnyPublisher()
                    }
                    else {
                        
                        let aemDataParser = ArticleAemDataParser()
                        
                        let aemParserResult: Result<ArticleAemData, ArticleAemDataParserError> = aemDataParser.parse(
                            aemUrl: aemUrl,
                            aemJson: jsonDictionary
                        )
                        
                        switch aemParserResult {
                        
                        case .success(let articleAemData):
                            
                            return Just(AemUriDownloadResult(articleAemData: articleAemData, downloadError: nil))
                                .eraseToAnyPublisher()

                        case .failure(let aemParserError):
                            
                            let error: ArticleAemDownloadOperationError = .failedToParseJson(error: aemParserError)
                            return Just(AemUriDownloadResult(articleAemData: nil, downloadError: error))
                                .eraseToAnyPublisher()
                        }
                    }
                }
                else {
                    
                    let responseError: Error = NSError(
                        domain: errorDomain,
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "The request failed with a status code: \(httpStatusCode)"
                    ])
                    
                    let error: ArticleAemDownloadOperationError = .httpError(error: responseError)
                    
                    return Just(AemUriDownloadResult(articleAemData: nil, downloadError: error))
                        .eraseToAnyPublisher()
                }
            }
            .catch { (error: Error) in
                
                let errorCode: Int = (error as NSError).code
                let operationError: ArticleAemDownloadOperationError
                
                if errorCode == CFNetworkErrors.cfurlErrorCancelled.rawValue {
                    operationError = .cancelled
                }
                else if errorCode == CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue {
                    operationError = .noNetworkConnection
                }
                else {
                    operationError = .unknownError(error: error)
                }
                
                return Just(AemUriDownloadResult(articleAemData: nil, downloadError: operationError))
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
