//
//  ImageCacheObject.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ImageCacheObject {
    
    let key: String
    let imageData: Data
    
    var lastAccessDate: Date = Date()
    
    required init(key: String, imageData: Data) {
        
        self.key = key
        self.imageData = imageData
    }
}
