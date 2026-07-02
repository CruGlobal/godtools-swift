//
//  ArticleAemDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class ArticleAemDownloader: ArticleAemDownloaderInterface {
            
    private let urlSessionPriority: URLSessionPriority
    private let requestSender: RequestSenderInterface
    private let maxAemJsonTreeLevels: Int = 9999
        
    init(urlSessionPriority: URLSessionPriority, requestSender: RequestSenderInterface) {
        
        self.urlSessionPriority = urlSessionPriority
        self.requestSender = requestSender
    }
    
    func download(aemUris: [String], downloadCachePolicy: ArticleAemDownloaderCachePolicy, requestPriority: RequestPriority) async throws -> ArticleAemDownload {
        
        let results: [DownloadArticleAemResult] = try await downloadAemUris(
            aemUris: aemUris,
            downloadCachePolicy: downloadCachePolicy,
            requestPriority: requestPriority
        )
        
        var aemDataObjects: [ArticleAemData] = Array()
        var errors: [Error] = Array()
        
        for result in results {
            
            if let aemDataObject = result.data {
                aemDataObjects.append(aemDataObject)
            }
            
            if let error = result.error {
                errors.append(error)
            }
        }
        
        return ArticleAemDownload(
            aemDataObjects: aemDataObjects,
            errors: errors
        )
    }
    
    private func downloadAemUris(aemUris: [String], downloadCachePolicy: ArticleAemDownloaderCachePolicy, requestPriority: RequestPriority) async throws -> [DownloadArticleAemResult] {
        
        try await withThrowingTaskGroup(of: DownloadArticleAemResult.self) { group in
            
            for aemUri in aemUris {
                group.addTask {
                    do {
                        let aemData: ArticleAemData = try await self.downloadAemUri(
                            aemUri: aemUri,
                            downloadCachePolicy: downloadCachePolicy,
                            requestPriority: requestPriority
                        )
                        return DownloadArticleAemResult(data: aemData, error: nil)
                    }
                    catch let error {
                        
                        if error.isUrlErrorNotConnectedToInternetCode || error.isUrlErrorCancelledCode {
                            throw error
                        }
                        
                        return DownloadArticleAemResult(data: nil, error: error)
                    }
                }
            }
            
            var results: [DownloadArticleAemResult] = Array()
            
            for try await result in group {
                results.append(result)
            }
            
            return results
        }
    }
    
    private func downloadAemUri(aemUri: String, downloadCachePolicy: ArticleAemDownloaderCachePolicy, requestPriority: RequestPriority) async throws -> ArticleAemData {
        
        guard let aemUrl = URL(string: aemUri) else {
            throw NSError.errorWithDescription(description: "Failed to create aem url from string.")
        }
        
        let cacheTimeInterval: TimeInterval = downloadCachePolicy.getCacheTimeInterval()
        
        let urlJsonString: String = aemUri + "." + String(maxAemJsonTreeLevels) + ".json?_=\(cacheTimeInterval)"
        
        guard let urlJson: URL = URL(string: urlJsonString) else {
            throw NSError.errorWithDescription(description: "Failed to create json url from string.")
        }
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest = URLRequest(
            url: urlJson,
            cachePolicy: urlSession.configuration.requestCachePolicy,
            timeoutInterval: urlSession.configuration.timeoutIntervalForRequest
        )
        
        let response: RequestDataResponse = try await requestSender.sendDataTask(
            urlRequest: urlRequest,
            urlSession: urlSession
        )
        
        let httpStatusCode: Int = response.urlResponse.httpStatusCode ?? -1
        let isSuccessHttpStatusCode: Bool = response.urlResponse.isSuccessHttpStatusCode
        
        guard isSuccessHttpStatusCode else {
            throw NSError.errorWithDescription(description: "The request failed with a status code: \(httpStatusCode)")
        }
        
        let json: Any = try JSONSerialization.jsonObject(with: response.data, options: [])
        
        guard let jsonDictionary = json as? [String: Any], !jsonDictionary.isEmpty else {
            throw NSError.errorWithDescription(description: "Failed to parse jsonData because data does not exist.")
        }
        
        let aemDataParser = ArticleAemDataParser()
        
        return try aemDataParser.parse(
            aemUrl: aemUrl,
            aemJson: jsonDictionary
        )
    }
}
