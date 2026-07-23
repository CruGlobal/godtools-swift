//
//  ArticleWebArchiver.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Fuzi

final class ArticleWebArchiver: ArticleWebArchiverInterface {
    
    private let urlSessionPriority: URLSessionPriority
    private let requestSender: RequestSenderInterface
    private let includeJavascript: Bool = true
    private let errorDomain: String = "ArticleWebArchiver"
        
    init(urlSessionPriority: URLSessionPriority, requestSender: RequestSenderInterface) {
        
        self.urlSessionPriority = urlSessionPriority
        self.requestSender = requestSender
    }
    
    func archive(webArchiveUrls: [WebArchiveUrl], requestPriority: RequestPriority) async -> [ArticleWebArchiveData] {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
                
        var archives: [ArticleWebArchiveData] = Array()
        
        await withTaskGroup(of: ArticleWebArchiveData.self) { group in
            
            for webArchiveUrl in webArchiveUrls {
                group.addTask {
                    let webArchiveData: ArticleWebArchiveData = await self.archiveUrl(
                        webArchiveUrl: webArchiveUrl,
                        urlSession: urlSession
                    )
                    return webArchiveData
                }
            }
            
            for await webArchiveData in group {
                archives.append(webArchiveData)
            }
        }
        
        return archives
    }
        
    private func archiveUrl(webArchiveUrl: WebArchiveUrl, urlSession: URLSession) async -> ArticleWebArchiveData {
        
        do {
            
            let htmlDocumentData = try await requestHtmlDocumentData(
                url: webArchiveUrl.webUrl,
                includeJavascript: includeJavascript,
                urlSession: urlSession
            )
            
            let htmlDocumentResources: [HTMLDocumentResource] = await requestHtmlDocumentResources(
                resourceUrls: htmlDocumentData.resourceUrls,
                urlSession: urlSession
            )
            
            let errors: [Error] = htmlDocumentResources.compactMap { $0.error }
            
            if let error = errors.first {
                return ArticleWebArchiveData.createWithError(webArchiveUrl: webArchiveUrl, error: error)
            }
            
            let webArchive = WebArchive(
                mainResource: htmlDocumentData.mainResource,
                webSubresources: htmlDocumentResources.compactMap { $0.resource }
            )
            
            let plistEncoder = PropertyListEncoder()
            plistEncoder.outputFormat = .binary
            
            let plistData: Data = try plistEncoder.encode(webArchive)
            
            return ArticleWebArchiveData.createWithData(webArchiveUrl: webArchiveUrl, webArchivePlistData: plistData)
        }
        catch let error {
            
            return ArticleWebArchiveData.createWithError(webArchiveUrl: webArchiveUrl, error: error)
        }
    }
    
    private func requestHtmlDocumentData(url: URL, includeJavascript: Bool, urlSession: URLSession) async throws -> HTMLDocumentData {
        
        guard let host = url.host else {
            throw NSError.errorWithDomain(domain: errorDomain, code: -1, description: "Invalid url host.")
        }
        
        let urlRequest: URLRequest = URLRequest(url: url)
        
        let response: RequestDataResponse = try await requestSender.sendDataTask(urlRequest: urlRequest, urlSession: urlSession)
        
        let httpStatusCode: Int = response.urlResponse.httpStatusCode ?? -1
        let isSuccessHttpStatusCode: Bool = response.urlResponse.isSuccessHttpStatusCode
        let mimeType: String = response.urlResponse.mimeType ?? ""
        
        if !isSuccessHttpStatusCode {
            
            throw NSError.errorWithDomain(domain: errorDomain, code: -1, description: "The request failed with a status code: \(httpStatusCode)")
        }
        else if mimeType != "text/html" {
            
            throw NSError.errorWithDomain(domain: errorDomain, code: -1, description: "Failed to archive url because the mimetype is not text/html. Found mimeType: \(mimeType)")
        }
        else if let htmlString = String(data: response.data, encoding: .utf8) {
            
            let webArchiveResource: WebArchiveResource = WebArchiveResource(url: url, data: response.data, mimeType: mimeType)
            let mainResource: WebArchiveMainResource = WebArchiveMainResource(baseResource: webArchiveResource)
            
            // NOTE: Using HTMLDocumentWrapper for now with open PR fix until merged and Fuzi is updated. ~Levi
            // TODO: GT-2492 Remove HTMLDocumentWrapper once PR is merged. ~Levi
            //let htmlDocument: HTMLDocument = try HTMLDocument(string: htmlString, encoding: .utf8)
            let htmlDocument: HTMLDocument = try HTMLDocumentWrapper(string: htmlString, encoding: .utf8).htmlDocument
            let resourceUrls: [String] = htmlDocument.getHTMLReferences(host: host, includeJavascript: includeJavascript)
            
            return HTMLDocumentData(
                mainResource: mainResource,
                resourceUrls: resourceUrls
            )
        }

        throw NSError.errorWithDomain(domain: errorDomain, code: -1, description: "Failed to archive url there wasn't sufficent html to parse.")
    }
    
    private func requestHtmlDocumentResources(resourceUrls: [String], urlSession: URLSession) async -> [HTMLDocumentResource] {
        
        var resources: [HTMLDocumentResource] = Array()
        
        await withTaskGroup(of: HTMLDocumentResource.self) { group in
            
            for urlString in resourceUrls {
                
                guard let url = URL(string: urlString) else {
                    continue
                }
                
                group.addTask {
                    do {
                        let archiveResource = try await self.requestHtmlDocumentResource(
                            url: url,
                            urlSession: urlSession
                        )
                        return HTMLDocumentResource.createWithResource(resource: archiveResource)
                    }
                    catch let error {
                        return HTMLDocumentResource.createWithError(error: error)
                    }
                }
            }
            
            for await result in group {
                resources.append(result)
            }
        }
        
        return resources
    }
    
    private func requestHtmlDocumentResource(url: URL, urlSession: URLSession) async throws -> WebArchiveResource {
        
        let urlRequest = URLRequest(url: url)
        
        let response: RequestDataResponse = try await requestSender.sendDataTask(
            urlRequest: urlRequest,
            urlSession: urlSession
        )
        
        let httpStatusCode: Int = response.urlResponse.httpStatusCode ?? -1
        let isSuccessHttpStatusCode: Bool = response.urlResponse.isSuccessHttpStatusCode
        let mimeType: String = response.urlResponse.mimeType ?? ""
        
        guard isSuccessHttpStatusCode else {
            throw NSError.errorWithDomain(domain: errorDomain, code: -1, description: "The requested html document resource failed with status code: \(httpStatusCode)")
        }
        
        guard !mimeType.isEmpty else {
            throw NSError.errorWithDomain(domain: errorDomain, code: -1, description: "The requested html document resource mimeType is empty.")
        }
        
        let webArchiveResource = WebArchiveResource(
            url: url,
            data: response.data,
            mimeType: mimeType
        )
        
        return webArchiveResource
    }
}
