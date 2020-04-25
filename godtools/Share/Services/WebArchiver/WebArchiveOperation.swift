//
//  WebArchiveOperation.swift
//  godtools
//
//  Created by Levi Eggert on 4/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Fuzi

class WebArchiveOperation: Operation {
    
    struct HTMLDocumentData {
        let mainResource: WebArchiveMainResource
        let htmlDocument: HTMLDocument
        let resourceUrls: [String]
    }
    
    typealias Completion = ((_ result: Result<Data?, Error>) -> Void)
    
    enum ObserverKey: String {
        case isExecuting = "isExecuting"
        case isFinshed = "isFinished"
    }
    
    enum State {
        case executing
        case finished
        case notStarted
    }
        
    private let session: URLSession
    private let url: URL
    private let urlRequest: URLRequest
    private let includeJavascript: Bool = true
    private let errorDomain: String = String(describing: WebArchiveOperation.self)
    
    private var getHtmlDocumentTask: URLSessionDataTask?
    private var getHtmlResourceTask: URLSessionDataTask?
    private var completion: Completion?
    
    required init(session: URLSession, url: URL) {
        self.session = session
        self.url = url
        self.urlRequest = URLRequest(url: url)
        super.init()
    }
    
    func completionHandler(completion: @escaping Completion) {
        self.completion = completion
    }
    
    override func start() {
                
        requestHtmlDocumentData(url: url, includeJavascript: includeJavascript) { [weak self] (_ result: Result<HTMLDocumentData, Error>) in
            
            switch result {
                
            case .success(let documentData):
                
                var resourceUrls: [String] = documentData.resourceUrls
                
                self?.requestHtmlDocumentResourcesSerially(resourceUrls: &resourceUrls, complete: { [weak self] (resources: [WebArchiveResource]) in
                    
                    let webArchive = WebArchive(
                        mainResource: documentData.mainResource,
                        webSubresources: resources
                    )
                    
                    let plistEncoder = PropertyListEncoder()
                    plistEncoder.outputFormat = .binary
                    
                    do {
                        let plistData: Data = try plistEncoder.encode(webArchive)
                        self?.handleOperationFinished(webArchivePlistData: plistData, error: nil)
                    }
                    catch let error {
                        self?.handleOperationFinished(webArchivePlistData: nil, error: error)
                    }
                })
            
            case .failure(let error):
            
                self?.handleOperationFinished(webArchivePlistData: nil, error: error)
            }
        }
        
        state = .executing
    }
    
    private func requestHtmlDocumentResourcesSerially(resourceUrls: inout [String], complete: @escaping ((_ resources: [WebArchiveResource]) -> Void)) {
                
        var fetchedResources: [WebArchiveResource] = Array()
        
        if let resourceUrl = getNextResourceUrl(resourceUrls: &resourceUrls) {
            
            var remainingResourceUrls: [String] = resourceUrls
                        
            requestHtmlDocumentResources(resourceUrl: resourceUrl) { [weak self] (result: Result<WebArchiveResource, Error>) in
                
                switch result {
                case .success(let webArchiveResource):
                    fetchedResources.append(webArchiveResource)
                case .failure( _):
                    break
                }
                
                //continue fetching resources
                self?.requestHtmlDocumentResourcesSerially(resourceUrls: &remainingResourceUrls, complete: complete)
            }
        }
        else {
            
            complete(fetchedResources)
        }
    }
    
    private func getNextResourceUrl(resourceUrls: inout [String]) -> URL? {
        
        var nextResourceUrl: URL?
        
        while !resourceUrls.isEmpty && nextResourceUrl == nil {
            
            let resourceUrl: String = resourceUrls[0]
            resourceUrls.remove(at: 0)
            
            nextResourceUrl = URL(string: resourceUrl)
        }
        
        return nextResourceUrl
    }
    
    private func requestHtmlDocumentResources(resourceUrl: URL, complete: @escaping ((_ result: Result<WebArchiveResource, Error>) -> Void)) {
                
        guard !isCancelled else {
            handleOperationCancelled()
            return
        }
        
        getHtmlResourceTask = session.dataTask(with: url, completionHandler: { [weak self] (data: Data?, urlResponse: URLResponse?, error: Error?) in
                        
            let httpStatusCode: Int = (urlResponse as? HTTPURLResponse)?.statusCode ?? -1
            let mimeType: String = urlResponse?.mimeType ?? ""
            
            if let error = error {
                
                complete(.failure(error))
            }
            else if httpStatusCode == 200, let data = data, !mimeType.isEmpty {
                
                let resource = WebArchiveResource(
                    url: resourceUrl,
                    data: data,
                    mimeType: mimeType
                )
                
                complete(.success(resource))
            }
            else {
                
                let noHtmlData = NSError(
                    domain: self?.errorDomain ?? "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to fetch resource, there wasn't sufficent html to parse."
                ])
                
                complete(.failure(noHtmlData))
            }
        })
        
        getHtmlResourceTask?.resume()
    }
    
    private func requestHtmlDocumentData(url: URL, includeJavascript: Bool, complete: @escaping ((_ result: Result<HTMLDocumentData, Error>) -> Void)) {
        
        guard !isCancelled else {
            handleOperationCancelled()
            return
        }
        
        guard let host = url.host else {
            
            let error = NSError(
                domain: errorDomain,
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid url host."
            ])
            
            complete(.failure(error))
            return
        }
        
        let urlRequest: URLRequest = URLRequest(url: url)
        
        getHtmlDocumentTask = session.dataTask(with: urlRequest) { [weak self] (data: Data?, urlResponse: URLResponse?, error: Error?) in
            
            let httpStatusCode: Int = (urlResponse as? HTTPURLResponse)?.statusCode ?? -1
            let mimeType: String = urlResponse?.mimeType ?? ""
                            
            if let error = error {
                complete(.failure(error))
            }
            else if httpStatusCode != 200 {
                
                let responseError = NSError(
                    domain: self?.errorDomain ?? "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "The request failed with a status code: \(httpStatusCode)"
                ])
                
                complete(.failure(responseError))
            }
            else if mimeType != "text/html" {
                
                let invalideMimeTypeError = NSError(
                    domain: self?.errorDomain ?? "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to archive url because the mimetype is not text/html. Found mimeType: \(mimeType)"
                ])
                
                complete(.failure(invalideMimeTypeError))
            }
            else if let data = data, let htmlString = String(data: data, encoding: .utf8) {
                do {
                    let webArchiveResource: WebArchiveResource = WebArchiveResource(url: url, data: data, mimeType: mimeType)
                    let mainResource: WebArchiveMainResource = WebArchiveMainResource(baseResource: webArchiveResource)
                    let htmlDocument: HTMLDocument = try HTMLDocument(string: htmlString, encoding: .utf8)
                    let resourceUrls: [String] = htmlDocument.getHTMLReferences(host: host, includeJavascript: includeJavascript)
                    complete(.success(HTMLDocumentData(mainResource: mainResource, htmlDocument: htmlDocument, resourceUrls: resourceUrls)))
                }
                catch let parseHtmlDocumentError {
                    complete(.failure(parseHtmlDocumentError))
                }
            }
            else {
                
                let noHtmlData = NSError(
                    domain: self?.errorDomain ?? "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to archive url there wasn't sufficent html to parse."
                ])
                
                complete(.failure(noHtmlData))
            }
        }
        
        getHtmlDocumentTask?.resume()
    }
    
    override func cancel() {
        super.cancel()
        getHtmlDocumentTask?.cancel()
        getHtmlResourceTask?.cancel()
    }
    
    private func handleOperationCancelled() {
        
        let cancelledError = NSError(
            domain: errorDomain,
            code: NSURLErrorCancelled,
            userInfo: [NSLocalizedDescriptionKey: "The operation was cancelled."]
        )
        
        handleOperationFinished(webArchivePlistData: nil, error: cancelledError)
    }
    
    private func handleOperationFinished(webArchivePlistData: Data?, error: Error?) {
             
        state = .finished
        
        guard let completion = completion else {
            return
        }
        
        var result: Result<Data?, Error>
        
        if let error = error {
            result = .failure(error)
        }
        else if let webArchivePlistData = webArchivePlistData {
            result = .success(webArchivePlistData)
        }
        else {
            result = .failure(unknownError)
        }
                
        completion(result)
    }
    
    private var unknownError: Error {
        return NSError(
            domain: errorDomain,
            code: NSURLErrorCancelled,
            userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred."]
        )
    }
    
    // MARK: - State
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    private var state: State = .notStarted {
        willSet (value) {
            switch value {
            case .executing:
                willChangeValue(forKey: ObserverKey.isExecuting.rawValue)
            case .finished:
                willChangeValue(forKey: ObserverKey.isFinshed.rawValue)
            case .notStarted:
                break
            }
        }
        didSet {
            switch state {
            case .executing:
                didChangeValue(forKey: ObserverKey.isExecuting.rawValue)
            case .finished:
                didChangeValue(forKey: ObserverKey.isFinshed.rawValue)
            case .notStarted:
                break
            }
        }
    }
}
