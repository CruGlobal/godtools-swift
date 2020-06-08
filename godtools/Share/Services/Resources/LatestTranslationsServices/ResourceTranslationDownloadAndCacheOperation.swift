//
//  ResourceTranslationDownloadAndCacheOperation.swift
//  godtools
//
//  Created by Levi Eggert on 5/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourceTranslationDownloadAndCacheOperation: Operation {
    
    typealias Completion = ((_ result: Result<ResourceTranslationDownloadAndCacheOperationResult, ResourceTranslationDownloadAndCacheOperationError>) -> Void)
    
    enum ObserverKey: String {
        case isExecuting = "isExecuting"
        case isFinshed = "isFinished"
    }
    
    enum State {
        case executing
        case finished
        case notStarted
    }
    
    private let resource: GodToolsResource
    private let session: URLSession
    private let translationsCache: ResourcesLatestTranslationsFileCache
    private let urlRequest: URLRequest
    private let errorDomain: String = String(describing: ResourceTranslationDownloadAndCacheOperation.self)
    
    private var task: URLSessionDataTask?
    private var completion: Completion?
    
    required init(resource: GodToolsResource, translationsApi: TranslationsApiType, translationsCache: ResourcesLatestTranslationsFileCache) {
        self.resource = resource
        self.session = translationsApi.session
        self.translationsCache = translationsCache
        self.urlRequest = translationsApi.newTranslationZipDataRequest(translationId: resource.translationId)
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
        
        let cacheLocation = ResourcesLatestTranslationsFileCacheLocation(
            godToolsResource: resource
        )
        
        task = session.dataTask(with: urlRequest) { [weak self] (data: Data?, urlResponse: URLResponse?, error: Error?) in
            
            if let isCancelled = self?.isCancelled {
                guard !isCancelled else {
                    self?.handleOperationCancelled()
                    return
                }
            }
            
            let httpStatusCode: Int = (urlResponse as? HTTPURLResponse)?.statusCode ?? -1
            let httpRequestSuccess: Bool = httpStatusCode >= 200 && httpStatusCode < 400
                            
            if error != nil || !httpRequestSuccess {
                
                self?.handleTranslationZipDataRequestFailed(requestError: error, httpStatusCode: httpStatusCode)
            }
            else if let zipData = data, let resource = self?.resource  {
                
                let cacheError: Error? = self?.translationsCache.cacheTranslationZipData(
                    cacheLocation: cacheLocation,
                    zipData: zipData
                )
                
                if let cacheError = cacheError {
                    self?.handleOperationFinished(result: .failure(.failedToCacheTranslationZipData(error: cacheError)))
                }
                else {
                    let result = ResourceTranslationDownloadAndCacheOperationResult(
                        resource: resource,
                        translationZipData: zipData,
                        cacheLocation: cacheLocation
                    )
                    
                    self?.handleOperationFinished(result: .success(result))
                }
            }
            else {
                
                let error: Error = NSError(
                    domain: self?.errorDomain ?? "",
                    code: NSURLErrorCancelled,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to cache zip data.  Data does not exist."]
                )
                self?.handleOperationFinished(result: .failure(.failedToCacheTranslationZipData(error: error)))
            }
        }
        
        task?.resume()
        
        state = .executing
    }
    
    override func cancel() {
        super.cancel()
        task?.cancel()
    }
    
    private func handleTranslationZipDataRequestFailed(requestError: Error?, httpStatusCode: Int) {
        
        if let requestError = requestError {
            
            let requestErrorCode: Int = (requestError as NSError).code
            
            if requestErrorCode == Int(CFNetworkErrors.cfurlErrorCancelled.rawValue) {
                handleOperationFinished(result: .failure(.cancelled))
            }
            else if requestErrorCode == Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue) {
                handleOperationFinished(result: .failure(.noNetworkConnection))
            }
            else {
                handleOperationFinished(result: .failure(.unknownError(error: requestError)))
            }
        }
        else {
            let error: Error = NSError(
                domain: errorDomain,
                code: NSURLErrorCancelled,
                userInfo: [NSLocalizedDescriptionKey: "The request failed with httpStatusCode: \(httpStatusCode)."]
            )
            handleOperationFinished(result: .failure(.unknownError(error: error)))
        }
    }
    
    private func handleOperationCancelled() {
        handleOperationFinished(result: .failure(.cancelled))
    }
    
    private func handleOperationFinished(result: Result<ResourceTranslationDownloadAndCacheOperationResult, ResourceTranslationDownloadAndCacheOperationError>) {
        
        state = .finished
        
        completion?(result)
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
