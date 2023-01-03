//
//  WebArchiveOperation.swift
//  godtools
//
//  Created by Levi Eggert on 4/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Fuzi
import RequestOperation

class WebArchiveOperation: Operation {
    
    typealias Completion = ((_ result: Result<WebArchiveOperationResult, WebArchiveOperationError>) -> Void)
    
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
    private let webArchiveUrl: WebArchiveUrl
    private let urlRequest: URLRequest
    private let includeJavascript: Bool = true
    private let errorDomain: String = String(describing: WebArchiveOperation.self)
    private let getHtmlResourcesQueue: OperationQueue = OperationQueue()
    
    private var getHtmlDocumentTask: URLSessionDataTask?
    private var completion: Completion?
    
    init(session: URLSession, webArchiveUrl: WebArchiveUrl) {
        
        self.session = session
        self.webArchiveUrl = webArchiveUrl
        self.urlRequest = URLRequest(url: webArchiveUrl.webUrl)
        
        super.init()
    }
    
    func completionHandler(completion: @escaping Completion) {
        self.completion = completion
    }
    
    override func start() {
                        
        let webArchiveUrl: WebArchiveUrl = self.webArchiveUrl
        
        requestHtmlDocumentData(url: webArchiveUrl.webUrl, includeJavascript: includeJavascript) { [weak self] (_ result: Result<HTMLDocumentData, WebArchiveOperationError>) in
            
            switch result {
                
            case .success(let documentData):
                                
                self?.requestHtmlDocumentResources(resourceUrls: documentData.resourceUrls, complete: { [weak self] (resources: [WebArchiveResource]) in
                           
                    if let operation = self {
                        guard !operation.isCancelled else {
                            self?.handleOperationCancelled()
                            return
                        }
                    }
                    
                    let webArchive = WebArchive(
                        mainResource: documentData.mainResource,
                        webSubresources: resources
                    )
                    
                    let plistEncoder = PropertyListEncoder()
                    plistEncoder.outputFormat = .binary
                    
                    do {
                        let plistData: Data = try plistEncoder.encode(webArchive)
                        let webArchiveResult = WebArchiveOperationResult(webArchiveUrl: webArchiveUrl, webArchivePlistData: plistData)
                        self?.handleOperationFinished(result: .success(webArchiveResult))
                    }
                    catch let error {
                        
                        self?.handleOperationFinished(result: .failure(.failedEncodingPlistData(error: error)))                        
                    }
                })
            
            case .failure(let webArchiveOperationError):
                self?.handleOperationFinished(result: .failure(webArchiveOperationError))
            }
        }
        
        state = .executing
    }
    
    private func requestHtmlDocumentResources(resourceUrls: [String], complete: @escaping ((_ resources: [WebArchiveResource]) -> Void)) {
        
        guard !isCancelled else {
            handleOperationCancelled()
            return
        }
        
        var fetchedWebArchiveResources: [WebArchiveResource] = Array()
        
        var resourceOperations: [RequestOperation] = Array()
        
        for resourceUrlString in resourceUrls {
            
            if let resourceUrl = URL(string: resourceUrlString) {
                
                let operation = RequestOperation(session: session, urlRequest: URLRequest(url: resourceUrl))
                
                operation.setCompletionHandler { [weak self] (response: RequestResponse) in
                    
                    let httpStatusCode: Int = response.httpStatusCode ?? -1
                    let httpStatusCodeSuccess: Bool = httpStatusCode >= 200 && httpStatusCode < 400
                    let mimeType: String = response.urlResponse?.mimeType ?? ""
                                        
                    if let _ = response.requestError {
                        
                        // TODO: Do something with Error? ~Levi
                    }
                    else if httpStatusCodeSuccess, let data = response.data, !mimeType.isEmpty {
                        
                        let webArchiveResource = WebArchiveResource(
                            url: resourceUrl,
                            data: data,
                            mimeType: mimeType
                        )
                        
                        fetchedWebArchiveResources.append(webArchiveResource)
                    }
                    else {
                        
                        // TODO: Do something with Error? ~Levi
                        
                        /*
                        let noDataError: Error = NSError(
                            domain: self?.errorDomain ?? "",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Failed to fetch resource."
                        ])*/
                    }
                    
                    if let queue = self?.getHtmlResourcesQueue, queue.operations.isEmpty {
                        complete(fetchedWebArchiveResources)
                    }
                }
                
                resourceOperations.append(operation)
            }
        }
        
        getHtmlResourcesQueue.addOperations(
            resourceOperations,
            waitUntilFinished: false
        )
    }
    
    private func requestHtmlDocumentData(url: URL, includeJavascript: Bool, complete: @escaping ((_ result: Result<HTMLDocumentData, WebArchiveOperationError>) -> Void)) {
        
        guard !isCancelled else {
            handleOperationCancelled()
            return
        }
        
        guard let host = url.host else {
            
            let error: Error = NSError(
                domain: errorDomain,
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid url host."
            ])
            
            complete(.failure(.invalidHost(error: error)))
            return
        }
        
        let urlRequest: URLRequest = URLRequest(url: url)
                
        getHtmlDocumentTask = session.dataTask(with: urlRequest) { [weak self] (data: Data?, urlResponse: URLResponse?, error: Error?) in
            
            let httpStatusCode: Int = (urlResponse as? HTTPURLResponse)?.statusCode ?? -1
            let mimeType: String = urlResponse?.mimeType ?? ""
               
            if let error = error {
                
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
                
                complete(.failure(operationError))                
            }
            else if httpStatusCode < 200 || httpStatusCode >= 400 {
                
                let error: Error = NSError(
                    domain: self?.errorDomain ?? "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "The request failed with a status code: \(httpStatusCode)"
                ])
                
                complete(.failure(.responseError(error: error)))
            }
            else if mimeType != "text/html" {
                
                let error: Error = NSError(
                    domain: self?.errorDomain ?? "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to archive url because the mimetype is not text/html. Found mimeType: \(mimeType)"
                ])
                
                complete(.failure(.invalidMimeType(error: error)))
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
                    complete(.failure(.failedToParseHtmlDocument(error: parseHtmlDocumentError)))
                }
            }
            else {
                
                let noHtmlData = NSError(
                    domain: self?.errorDomain ?? "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to archive url there wasn't sufficent html to parse."
                ])
                
                complete(.failure(.failedToParseHtmlDocument(error: noHtmlData)))
            }
        }
        
        getHtmlDocumentTask?.resume()
    }
    
    override func cancel() {
        super.cancel()
        getHtmlDocumentTask?.cancel()
        getHtmlResourcesQueue.cancelAllOperations()
    }
    
    private func handleOperationCancelled() {
        
        handleOperationFinished(result: .failure(.cancelled))
    }
    
    private func handleOperationFinished(result: Result<WebArchiveOperationResult, WebArchiveOperationError>) {
        
        state = .finished
        
        guard let completion = completion else {
            return
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
