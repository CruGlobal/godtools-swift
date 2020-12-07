//
//  ImageMemoryCache.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ImageMemoryCache {
    
    typealias Key = String
    
    private let maxCacheSizeInBytes: Int
    
    private var imageCache: [Key: ImageCacheObject] = Dictionary()
    private var currentCacheSizeInBytes: Int = 0
    private var isPurging: Bool = false
    
    required init(maxCacheSizeInMegabytes: Int) {
        
        maxCacheSizeInBytes = maxCacheSizeInMegabytes * 1024 * 1024
    }
    
    func getImageData(key: String) -> Data? {
        
        if let cacheObject = imageCache[key] {
            
            cacheObject.lastAccessDate = Date()
            
            return cacheObject.imageData
        }
        
        return nil
    }
    
    func cacheImageDataForKey(key: String, imageData: Data) {
        
        // TODO: Should we allow overwriting if imageData with key is already cached? ~Levi
        guard imageCache[key] == nil else {
            return
        }
        
        imageCache[key] = ImageCacheObject(key: key, imageData: imageData)
        
        currentCacheSizeInBytes += imageData.count
                
        purgeMemoryIfNeeded()
    }
    
    private func purgeMemoryIfNeeded() {
        
        guard currentCacheSizeInBytes > maxCacheSizeInBytes else {
            return
        }
        
        guard !isPurging else {
            return
        }
        
        isPurging = true
        
        DispatchQueue.global().async { [weak self] in
            
            var imageCacheCopy: [Key: ImageCacheObject] = self?.imageCache ?? Dictionary()
            let allCachedImages: [ImageCacheObject] = Array(imageCacheCopy.values)
            let maxCacheSizeInBytes: Int = self?.maxCacheSizeInBytes ?? 0
            var currentCacheSizeInBytes: Int = self?.currentCacheSizeInBytes ?? 0
            let oldestCachedImagesFirst: [ImageCacheObject] = allCachedImages.sorted(by: {$0.lastAccessDate < $1.lastAccessDate})
            
            var index: Int = 0
            
            while currentCacheSizeInBytes > maxCacheSizeInBytes && index < oldestCachedImagesFirst.count {
                
                let cacheObject: ImageCacheObject = oldestCachedImagesFirst[index]
                currentCacheSizeInBytes -= cacheObject.imageData.count
                imageCacheCopy[cacheObject.key] = nil
                
                index += 1
            }
            
            DispatchQueue.main.async { [weak self] in
                
                guard let memoryCache = self else {
                    return
                }
                
                memoryCache.imageCache = imageCacheCopy
                memoryCache.currentCacheSizeInBytes = currentCacheSizeInBytes
                memoryCache.isPurging = false
            }
        }
    }
}
