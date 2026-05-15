//
//  MobileContentTranslationsCdn.swift
//  godtools
//
//  Created by Levi Eggert on 5/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import GodToolsShared

final class MobileContentTranslationsCdn: TranslationsCdnInterface {
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let urlSessionPriority: URLSessionPriority
    private let requestSender: RequestSender
    private let baseUrl: String
    
    init(config: AppConfigInterface, urlSessionPriority: URLSessionPriority, requestSender: RequestSender) {
        
        self.urlSessionPriority = urlSessionPriority
        self.requestSender = requestSender
        baseUrl = config.getMobileContentCDNBaseUrl()
    }
    
    private func getManifestFileUrlRequest(urlSession: URLSession, manifestFile: ManifestFile) throws -> URLRequest {
        
        let fileName = try manifestFile.fileName
        
        return requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: urlSession,
                urlString: baseUrl + "/translations/files/" + fileName,
                method: .get,
                headers: nil,
                httpBody: nil,
                queryItems: nil
            )
        )
    }
    
    func getManifestFile(manifestFile: ManifestFile, requestPriority: RequestPriority) async throws -> RequestDataResponse {
                
        guard let checksumSha256 = manifestFile.checksumSha256, !checksumSha256.isEmpty else {
            throw NSError.errorWithDescription(description: "Missing checksumSha256.")
        }
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = try getManifestFileUrlRequest(urlSession: urlSession, manifestFile: manifestFile)
        
        let requestDataResponse = try await requestSender.sendDataTask(
            urlRequest: urlRequest,
            urlSession: urlSession
        )
        
        guard requestDataResponse.urlResponse.isSuccessHttpStatusCode else {
            throw NSError.errorWithDescription(description: "HTTP request failed.")
        }
        
        guard requestDataResponse.data.toSha256Hash() == checksumSha256.lowercased() else {
            
            throw NSError.errorWithDescription(description: "Failed to validate checksumSha256.")
        }
        
        return requestDataResponse
    }
}
