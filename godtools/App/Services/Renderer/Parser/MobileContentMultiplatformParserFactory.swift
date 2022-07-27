//
//  MobileContentMultiplatformParserFactory.swift
//  godtools
//
//  Created by Levi Eggert on 7/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentMultiplatformParserFactory: IosXmlPullParserFactory {
        
    private let resourcesFileCache: ResourcesSHA256FileCache
    
    required init(resourcesFileCache: ResourcesSHA256FileCache) {
        
        self.resourcesFileCache = resourcesFileCache
        
        super.init()
    }
    
    override func openFile(fileName: String) -> Data? {
                
        let location = FileCacheLocation(relativeUrlString: fileName)
                
        let result = resourcesFileCache.getData(location: location)
        
        switch result {
        
        case .success(let data):
            return data
            
        case .failure( _):
            return nil
        }
    }
}
