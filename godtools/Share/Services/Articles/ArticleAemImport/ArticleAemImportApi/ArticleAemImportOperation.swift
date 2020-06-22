//
//  ArticleAemImportOperation.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticleAemImportOperation: Operation {
    
    typealias Completion = ((_ response: RequestResponse, _ result: Result<ArticleAemImportData, ArticleAemImportOperationError>) -> Void)
    
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
    private let godToolsResource: GodToolsResource
    private let aemImportSrc: String
    private let maxAemImportJsonTreeLevels: Int
    private let errorDomain: String = String(describing: ArticleAemImportOperation.self)
    
    private var urlRequest: URLRequest?
    private var task: URLSessionDataTask?
    private var completion: Completion?
    
    required init(session: URLSession, godToolsResource: GodToolsResource, aemImportSrc: String, maxAemImportJsonTreeLevels: Int) {
        self.session = session
        self.godToolsResource = godToolsResource
        self.aemImportSrc = aemImportSrc
        self.maxAemImportJsonTreeLevels = maxAemImportJsonTreeLevels
        super.init()
    }
    
    func completionHandler(completion: @escaping Completion) {
        self.completion = completion
    }
    
    override func start() {
                
        guard !isCancelled else {
            handleOperationCancelled()
            return
        }
           
        guard let aemImportSrcUrl = URL(string: aemImportSrc) else {
            
            handleOperationFinished(
                articleAemImportData: nil,
                data: nil,
                urlResponse: nil,
                error: .invalidAemImportSrcUrl
            )
            
            return
        }
        
        let urlJsonString: String = aemImportSrc + "." + String(maxAemImportJsonTreeLevels) + ".json"
        
        guard let urlJson: URL = URL(string: urlJsonString) else {
            
            handleOperationFinished(
                articleAemImportData: nil,
                data: nil,
                urlResponse: nil,
                error: .invalidAemImportJsonUrl
            )
            
            return
        }
        
        let urlJsonRequest = URLRequest(
            url: urlJson,
            cachePolicy: session.configuration.requestCachePolicy,
            timeoutInterval: session.configuration.timeoutIntervalForRequest
        )
        
        let godToolsResourceRef = godToolsResource
        
        self.urlRequest = urlJsonRequest
        
        task = session.dataTask(with: urlJsonRequest) { [weak self] (data: Data?, urlResponse: URLResponse?, error: Error?) in
            
            if let operation = self {
                guard !operation.isCancelled else {
                    operation.handleOperationCancelled()
                    return
                }
            }
            
            let httpStatusCode: Int = (urlResponse as? HTTPURLResponse)?.statusCode ?? -1
            
            if let error = error {
                
                let errorCode: Int = (error as NSError).code
                let operationError: ArticleAemImportOperationError
                
                if errorCode == CFNetworkErrors.cfurlErrorCancelled.rawValue {
                    operationError = .cancelled
                }
                else if errorCode == CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue {
                    operationError = .noNetworkConnection
                }
                else {
                    operationError = .unknownError(error: error)
                }
                
                self?.handleOperationFinished(articleAemImportData: nil, data: data, urlResponse: urlResponse, error: operationError)
            }
            else if httpStatusCode < 200 || httpStatusCode >= 400 {
                
                let responseError = NSError(
                    domain: self?.errorDomain ?? "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "The request failed with a status code: \(httpStatusCode)"
                ])
                
                self?.handleOperationFinished(articleAemImportData: nil, data: data, urlResponse: urlResponse, error: .unknownError(error: responseError))
            }
            else {

                // validate json
                var jsonDictionary: [String: Any] = Dictionary()
                var jsonError: Error?
                
                if let data = data {
                    do {
                        let json: Any = try JSONSerialization.jsonObject(with: data, options: [])
                        if let dictionary = json as? [String: Any] {
                            jsonDictionary = dictionary
                        }
                    }
                    catch let error {
                        jsonError = error
                    }
                }
                
                if jsonDictionary.isEmpty, jsonError == nil {
                    
                    jsonError = NSError(
                        domain: self?.errorDomain ?? "",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to parse jsonData because data does not exist."
                    ])
                }
                
                if let jsonError = jsonError {
                    
                    self?.handleOperationFinished(articleAemImportData: nil, data: data, urlResponse: urlResponse, error: .failedToSerializeJson(error: jsonError))
                }
                else {
                    
                    let aemImportDataParser = ArticleAemImportDataParser()
                    
                    let aemImportParserResult: Result<ArticleAemImportData, ArticleAemImportDataParserError> = aemImportDataParser.parse(
                        aemImportSrc: aemImportSrcUrl,
                        aemImportJson: jsonDictionary,
                        godToolsResource: godToolsResourceRef
                    )
                    
                    switch aemImportParserResult {
                    
                    case .success(let articleAemImportData):
                        
                        self?.handleOperationFinished(
                            articleAemImportData: articleAemImportData,
                            data: data,
                            urlResponse: urlResponse,
                            error: nil
                        )
                        
                    case .failure(let aemImportParserError):
                        
                        self?.handleOperationFinished(
                            articleAemImportData: nil,
                            data: data,
                            urlResponse: urlResponse,
                            error: .failedToParseJson(error: aemImportParserError)
                        )
                    }
                }
            }
        }
        
        task?.resume()
        state = .executing
    }
    
    override func cancel() {
        super.cancel()
        task?.cancel()
    }
    
    private func handleOperationCancelled() {
                
        handleOperationFinished(articleAemImportData: nil, data: nil, urlResponse: nil, error: .cancelled)
    }
    
    private var unknownError: Error {
        return NSError(
            domain: errorDomain,
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred."]
        )
    }
    
    private func handleOperationFinished(articleAemImportData: ArticleAemImportData?, data: Data?, urlResponse: URLResponse?, error: ArticleAemImportOperationError?) {
        
        state = .finished
        
        guard let completion = completion else {
            return
        }
        
        let response: RequestResponse = RequestResponse(
            urlRequest: urlRequest,
            data: data,
            urlResponse: urlResponse,
            requestError: error
        )
        
        var result: Result<ArticleAemImportData, ArticleAemImportOperationError>
        
        if let error = error {
            result = .failure(error)
        }
        else if let articleAemImportData = articleAemImportData {
            result = .success(articleAemImportData)
        }
        else {
            result = .failure(.unknownError(error: unknownError))
        }
                
        completion(response, result)
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
