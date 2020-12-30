//
//  RequestOperation.swift
//  godtools
//
//  Created by Levi Eggert on 2/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class RequestOperation: Operation {
    
    typealias Completion = ((_ response: RequestResponse) -> Void)
    
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
    private let urlRequest: URLRequest
    private let errorDomain: String = String(describing: RequestOperation.self)
    
    private var task: URLSessionDataTask?
    private var completion: Completion?
    
    required init(session: URLSession, urlRequest: URLRequest) {
        self.session = session
        self.urlRequest = urlRequest
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
        
        task = session.dataTask(with: urlRequest) { [weak self] (data: Data?, urlResponse: URLResponse?, error: Error?) in
            
            self?.handleOperationFinished(data: data, urlResponse: urlResponse, requestError: error)
        }
        
        task?.resume()
        state = .executing
    }
    
    override func cancel() {
        super.cancel()
        task?.cancel()
    }
    
    private func handleOperationCancelled() {
        
        let cancelledError: Error = NSError(
            domain: errorDomain,
            code: NSURLErrorCancelled,
            userInfo: [NSLocalizedDescriptionKey: "The operation was cancelled."]
        )
        
        handleOperationFinished(data: nil, urlResponse: nil, requestError: cancelledError)
    }
    
    private func handleOperationFinished(data: Data?, urlResponse: URLResponse?, requestError: Error?) {
        
        state = .finished
        
        let response = RequestResponse(
            urlRequest: urlRequest,
            data: data,
            urlResponse: urlResponse,
            requestError: requestError
        )
        
        completion?(response)
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
