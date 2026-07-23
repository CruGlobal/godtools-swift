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
    
    func download(
        aemUris: [String],
        downloadCachePolicy: ArticleAemDownloaderCachePolicy,
        requestPriority: RequestPriority
    ) async -> [ArticleAemData] {
        
        return await downloadAemUris(
            aemUris: aemUris,
            downloadCachePolicy: downloadCachePolicy,
            requestPriority: requestPriority
        )
    }
    
    private func downloadAemUris(
        aemUris: [String],
        downloadCachePolicy: ArticleAemDownloaderCachePolicy,
        requestPriority: RequestPriority
    ) async -> [ArticleAemData] {
        
        await withTaskGroup(of: ArticleAemData.self) { group in
            
            for aemUri in aemUris {
                group.addTask {
                    let aemData: ArticleAemData = await self.downloadAemUri(
                        aemUri: aemUri,
                        downloadCachePolicy: downloadCachePolicy,
                        requestPriority: requestPriority
                    )
                    return aemData
                }
            }
            
            var results: [ArticleAemData] = Array()
            
            for await result in group {
                results.append(result)
            }
            
            return results
        }
    }
    
    private func downloadAemUri(
        aemUri: String,
        downloadCachePolicy: ArticleAemDownloaderCachePolicy,
        requestPriority: RequestPriority
    ) async -> ArticleAemData {
        
        guard let aemUrl = URL(string: aemUri) else {
            return ArticleAemData.createWithError(
                aemUri: aemUri,
                error: NSError.errorWithDescription(description: "Failed to create aem url from string."),
                httpStatusCode: nil
            )
        }
        
        let cacheTimeInterval: TimeInterval = downloadCachePolicy.getCacheTimeInterval()
        
        let urlJsonString: String = aemUri + "." + String(maxAemJsonTreeLevels) + ".json?_=\(cacheTimeInterval)"
        
        guard let urlJson: URL = URL(string: urlJsonString) else {
            return ArticleAemData.createWithError(
                aemUri: aemUri,
                error: NSError.errorWithDescription(description: "Failed to create json url from string."),
                httpStatusCode: nil
            )
        }
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest = URLRequest(
            url: urlJson,
            cachePolicy: urlSession.configuration.requestCachePolicy,
            timeoutInterval: urlSession.configuration.timeoutIntervalForRequest
        )
        
        let response: RequestDataResponse
        
        do {
            response = try await requestSender.sendDataTask(
                urlRequest: urlRequest,
                urlSession: urlSession
            )
        }
        catch let responseError {
            return ArticleAemData.createWithError(
                aemUri: aemUri,
                error: responseError,
                httpStatusCode: nil
            )
        }
        
        let httpStatusCode: Int = response.urlResponse.httpStatusCode ?? -1
        let isSuccessHttpStatusCode: Bool = response.urlResponse.isSuccessHttpStatusCode
        
        guard isSuccessHttpStatusCode else {
            return ArticleAemData.createWithError(
                aemUri: aemUri,
                error: NSError.errorWithDescription(description: "The request failed with a status code: \(httpStatusCode)"),
                httpStatusCode: httpStatusCode
            )
        }
        
        let json: Any
        
        do {
            json = try JSONSerialization.jsonObject(with: response.data, options: [])
        }
        catch let jsonError {
            return ArticleAemData.createWithError(
                aemUri: aemUri,
                error: jsonError,
                httpStatusCode: nil
            )
        }
        
        guard let jsonDictionary = json as? [String: Any], !jsonDictionary.isEmpty else {
            return ArticleAemData.createWithError(
                aemUri: aemUri,
                error: NSError.errorWithDescription(description: "Failed to parse jsonData because data does not exist."),
                httpStatusCode: nil
            )
        }
        
        let aemDataParser = ArticleAemDataParser()
        
        return aemDataParser.parse(
            aemUrl: aemUrl,
            aemJson: jsonDictionary
        )
    }
}
