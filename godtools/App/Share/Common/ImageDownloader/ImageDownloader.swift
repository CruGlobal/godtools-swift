//
//  ImageDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 8/14/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import RequestOperation

class ImageDownloader {
    
    private let session: URLSession
    private let imageCache: ImageUrlCache
    
    init(imageCache: ImageUrlCache = ImageDownloader.defaultImageUrlCache) {
        
        // session
        let configuration: URLSessionConfiguration = URLSessionConfiguration.ephemeral
        
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        configuration.urlCache = nil
        
        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.never
        configuration.httpShouldSetCookies = false
        configuration.httpCookieStorage = nil
        
        configuration.timeoutIntervalForRequest = 60
        
        self.session = URLSession(configuration: configuration)
        
        // imageCache
        self.imageCache = imageCache
    }
    
    private static var defaultImageUrlCache: ImageUrlCache {
        return ImageUrlCache(memoryCapacityInMegabytes: 10, diskCapacityInMegabytes: 10, diskPath: "image_disk_path")
    }
    
    func getSession() -> URLSession {
        return session
    }
    
    func getImageCache() -> ImageUrlCache {
        return imageCache
    }
    
    func download(url: String?, completion: @escaping ((Result<UIImage?, RequestResponseError<NoHttpClientErrorResponse>>) -> Void)) -> OperationQueue? {
        
        if let urlString = url, let url = URL(string: urlString) {
            return download(url: url, completion: completion)
        }
        else {
            completion(.success(nil))
            return nil
        }
    }
    
    func download(url: URL, completion: @escaping ((Result<UIImage?, RequestResponseError<NoHttpClientErrorResponse>>) -> Void)) -> OperationQueue? {
        
        let urlRequest = URLRequest(url: url)
        
        if let cachedImageData = imageCache.getImageData(urlRequest: urlRequest), let cachedImage = UIImage(data: cachedImageData) {
            
            completion(.success(cachedImage))
            return nil
        }
        else {
            
            let operation: RequestOperation = RequestOperation(session: session, urlRequest: urlRequest)
            let queue: OperationQueue = OperationQueue()
            
            operation.setCompletionHandler { [weak self] (response: RequestResponse) in
                
                if let responseError = response.getResponseError() {
                    
                    completion(.failure(responseError))
                }
                else if let imageData = response.data {
                    
                    if let urlResponse = response.urlResponse {
                        self?.imageCache.storeImageData(imageData: imageData, urlResponse: urlResponse, urlRequest: urlRequest)
                    }
                    
                    let image: UIImage? = UIImage(data: imageData)
                    
                    completion(.success(image))
                }
                else {
                    
                    completion(.success(nil))
                }
            }
            
            queue.addOperations([operation], waitUntilFinished: false)
            
            return queue
        }
    }
}
