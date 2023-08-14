//
//  ImageUrlCache.swift
//  godtools
//
//  Created by Levi Eggert on 8/14/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

class ImageUrlCache {
    
    private let urlCache: URLCache
    
    init(memoryCapacityInMegabytes: Int, diskCapacityInMegabytes: Int, diskPath: String) {
        
        urlCache = URLCache(
            memoryCapacity: 1024 * 1024 * memoryCapacityInMegabytes,
            diskCapacity: 1024 * 1024 * diskCapacityInMegabytes,
            diskPath: diskPath
        )
    }
    
    func getImageData(urlRequest: URLRequest) -> Data? {
        return urlCache.cachedResponse(for: urlRequest)?.data
    }
    
    func storeImageData(imageData: Data, urlResponse: URLResponse, urlRequest: URLRequest) {
        urlCache.storeCachedResponse(CachedURLResponse(response: urlResponse, data: imageData), for: urlRequest)
    }
}
