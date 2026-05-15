//
//  MobileContentTranslationsApi.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import GodToolsShared

final class MobileContentTranslationsApi: TranslationsApiInterface {
    
    enum FileHost {
        case api
        case cdn
    }
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let urlSessionPriority: URLSessionPriority
    private let requestSender: RequestSender
    private let config: AppConfigInterface
    
    init(config: AppConfigInterface, urlSessionPriority: URLSessionPriority, requestSender: RequestSender) {
                    
        self.urlSessionPriority = urlSessionPriority
        self.requestSender = requestSender
        self.config = config
    }
    
    private func getFileBaseUrl(host: FileHost) -> String {
        switch host {
        case .api:
            return config.getMobileContentApiBaseUrl()
        case .cdn:
            return config.getMobileContentCDNBaseUrl()
        }
    }
    
    // MARK: - Files
    
    private func getTranslationFileRequest(urlSession: URLSession, host: FileHost, fileName: String) -> URLRequest {
        
        return requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: urlSession,
                urlString: getFileBaseUrl(host: host) + "/translations/files/" + fileName,
                method: .get,
                headers: nil,
                httpBody: nil,
                queryItems: nil
            )
        )
    }
    
    func getTranslationFile(file: TranslationFile, requestPriority: RequestPriority) async throws -> RequestDataResponse {
        
        switch file {
        
        case .manifestFile(let manifestFile):
            return try await getTranslationManifestFile(manifestFile: manifestFile, requestPriority: requestPriority)
            
        case .translationManifest(let translation):
            return try await getTranslationFileFromApi(fileName: translation.manifestName, requestPriority: requestPriority)
        }
    }
    
    private func getTranslationFileFromApi(fileName: String, requestPriority: RequestPriority) async throws -> RequestDataResponse {
            
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let apiUrlRequest: URLRequest = getTranslationFileRequest(urlSession: urlSession, host: .api, fileName: fileName)
        
        return try await requestSender.sendDataTask(
            urlRequest: apiUrlRequest,
            urlSession: urlSession
        )
    }
    
    private func getTranslationManifestFile(manifestFile: ManifestFile, requestPriority: RequestPriority) async throws -> RequestDataResponse {
        
        let fileName: String = try manifestFile.fileName
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        guard let checksumSha256 = manifestFile.checksumSha256, !checksumSha256.isEmpty else {
         
            return try await getTranslationFileFromApi(fileName: fileName, requestPriority: requestPriority)
        }
        
        return try await getTranslationFileFromCdnElseApi(
            fileName: fileName,
            checksumSha256: checksumSha256,
            urlSession: urlSession,
            requestPriority: requestPriority
        )
    }
    
    private func getTranslationFileFromCdnElseApi(fileName: String, checksumSha256: String, urlSession: URLSession, requestPriority: RequestPriority) async throws -> RequestDataResponse {
        
        guard !checksumSha256.isEmpty else {
            throw NSError.errorWithDescription(description: "Download translation file checksumSha256 can't be empty.")
        }
        
        let cdnUrlRequest: URLRequest = getTranslationFileRequest(urlSession: urlSession, host: .cdn, fileName: fileName)
        
        let requestDataResponse = try await requestSender.sendDataTask(
            urlRequest: cdnUrlRequest,
            urlSession: urlSession
        )
                           
        guard requestDataResponse.urlResponse.isSuccessHttpStatusCode &&
              requestDataResponse.data.toSha256Hash() == checksumSha256.lowercased() else {
            
            return try await getTranslationFileFromApi(
                fileName: fileName,
                requestPriority: requestPriority
            )
        }
        
        return requestDataResponse
    }
    
    // MARK: - Translation Zip File Data
    
    private func getTranslationZipFileRequest(urlSession: URLSession, translationId: String) -> URLRequest {
        
        return requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: urlSession,
                urlString: getFileBaseUrl(host: .api) + "/translations/" + translationId,
                method: .get,
                headers: nil,
                httpBody: nil,
                queryItems: nil
            )
        )
    }
    
    func getTranslationZipFile(translationId: String, requestPriority: RequestPriority) async throws -> RequestDataResponse {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = getTranslationZipFileRequest(urlSession: urlSession, translationId: translationId)
        
        return try await requestSender.sendDataTask(
            urlRequest: urlRequest,
            urlSession: urlSession
        )
    }
}
