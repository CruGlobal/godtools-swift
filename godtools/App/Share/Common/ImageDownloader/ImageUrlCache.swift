//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class ImageUrlCache {
    
    private let urlCache: URLCache
    
    required init(memoryCapacityInMegabytes: Int, diskCapacityInMegabytes: Int, diskPath: String) {
        
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
