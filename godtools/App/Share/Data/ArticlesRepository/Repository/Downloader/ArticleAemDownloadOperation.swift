//
//  ArticleAemDownloadOperation.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class ArticleAemDownloadOperation: Operation {
    
    typealias Completion = ((_ response: RequestResponse, _ result: Result<ArticleAemData, ArticleAemDownloadOperationError>) -> Void)
    
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
    private let aemUri: String
    private let maxAemJsonTreeLevels: Int
    private let cachePolicy: ArticleAemDownloadOperationCachePolicy
    private let errorDomain: String = String(describing: ArticleAemDownloadOperation.self)
    
    private var urlRequest: URLRequest?
    private var task: URLSessionDataTask?
    private var completion: Completion?
    
    init(session: URLSession, aemUri: String, maxAemJsonTreeLevels: Int, cachePolicy: ArticleAemDownloadOperationCachePolicy) {
        
        self.session = session
        self.aemUri = aemUri
        self.maxAemJsonTreeLevels = maxAemJsonTreeLevels
        self.cachePolicy = cachePolicy
       
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
           
        guard let aemUrl = URL(string: aemUri) else {
            
            handleOperationFinished(
                articleAemData: nil,
                data: nil,
                urlResponse: nil,
                error: .invalidAemSrcUrl
            )
            
            return
        }
                
        let cacheTimeInterval: TimeInterval = ArticleAemDownloadGetCacheTimeInterval().getCacheTimeInterval(cachePolicy: cachePolicy)
        
        let urlJsonString: String = aemUri + "." + String(maxAemJsonTreeLevels) + ".json?_=\(cacheTimeInterval)"
        
        guard let urlJson: URL = URL(string: urlJsonString) else {
            
            handleOperationFinished(
                articleAemData: nil,
                data: nil,
                urlResponse: nil,
                error: .invalidAemJsonUrl
            )
            
            return
        }
        
        let urlJsonRequest = URLRequest(
            url: urlJson,
            cachePolicy: session.configuration.requestCachePolicy,
            timeoutInterval: session.configuration.timeoutIntervalForRequest
        )
        
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
                
                self?.handleOperationFinished(articleAemData: nil, data: data, urlResponse: urlResponse, error: operationError)
            }
            else if httpStatusCode < 200 || httpStatusCode >= 400 {
                
                let responseError = NSError(
                    domain: self?.errorDomain ?? "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "The request failed with a status code: \(httpStatusCode)"
                ])
                
                self?.handleOperationFinished(articleAemData: nil, data: data, urlResponse: urlResponse, error: .unknownError(error: responseError))
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
                    
                    self?.handleOperationFinished(articleAemData: nil, data: data, urlResponse: urlResponse, error: .failedToSerializeJson(error: jsonError))
                }
                else {
                    
                    let aemDataParser = ArticleAemDataParser()
                    
                    let aemParserResult: Result<ArticleAemData, ArticleAemDataParserError> = aemDataParser.parse(
                        aemUrl: aemUrl,
                        aemJson: jsonDictionary
                    )
                    
                    switch aemParserResult {
                    
                    case .success(let articleAemData):
                        
                        self?.handleOperationFinished(
                            articleAemData: articleAemData,
                            data: data,
                            urlResponse: urlResponse,
                            error: nil
                        )
                        
                    case .failure(let aemParserError):
                        
                        self?.handleOperationFinished(
                            articleAemData: nil,
                            data: data,
                            urlResponse: urlResponse,
                            error: .failedToParseJson(error: aemParserError)
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
                
        handleOperationFinished(articleAemData: nil, data: nil, urlResponse: nil, error: .cancelled)
    }
    
    private var unknownError: Error {
        return NSError(
            domain: errorDomain,
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred."]
        )
    }
    
    private func handleOperationFinished(articleAemData: ArticleAemData?, data: Data?, urlResponse: URLResponse?, error: ArticleAemDownloadOperationError?) {
        
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
        
        var result: Result<ArticleAemData, ArticleAemDownloadOperationError>
        
        if let error = error {
            result = .failure(error)
        }
        else if let articleAemData = articleAemData {
            result = .success(articleAemData)
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
