//
//  ArticleAemDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class ArticleAemDownloader {
            
    private let urlSessionPriority: URLSessionPriority
    private let requestSender: RequestSender
    private let maxAemJsonTreeLevels: Int = 9999
        
    init(urlSessionPriority: URLSessionPriority, requestSender: RequestSender) {
        
        self.urlSessionPriority = urlSessionPriority
        self.requestSender = requestSender
    }
    
    func download(aemUris: [String], downloadCachePolicy: ArticleAemDownloaderCachePolicy, requestPriority: RequestPriority) async throws -> [ArticleAemData] {
        
        var aemDataObjects: [ArticleAemData] = Array()
        
        for aemUri in aemUris {
            
            let aemData: ArticleAemData = try await downloadAemUri(
                aemUri: aemUri,
                downloadCachePolicy: downloadCachePolicy,
                requestPriority: requestPriority
            )
            
            aemDataObjects.append(aemData)
        }
        
        return aemDataObjects
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
