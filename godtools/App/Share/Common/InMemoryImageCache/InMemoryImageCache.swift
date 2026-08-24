//
//  InMemoryImageCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/14/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SwiftUI

final class InMemoryImageCache: ImageCacheInterface {
    
    private final class CachedImage: Sendable {
        
        let image: Image
        
        init(image: Image) {
            
            self.image = image
        }
    }
    
    // Apple documents NSCache as thread safe and does its own internal locking. ~Levi
    private nonisolated(unsafe) let cache: NSCache<NSString, CachedImage> = NSCache<NSString, CachedImage>()
    
    init(countLimit: Int = 100) {
        
        cache.countLimit = countLimit
    }
    
    func cacheImage(id: String, image: Image) {
        
        cache.setObject(CachedImage(image: image), forKey: id as NSString)
    }
    
    func getImage(id: String) -> Image? {
        
        return cache.object(forKey: NSString(string: id))?.image
    }
}
