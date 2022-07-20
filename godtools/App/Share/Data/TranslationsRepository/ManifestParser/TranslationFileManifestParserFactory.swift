//
//  TranslationFileManifestParserFactory.swift
//  godtools
//
//  Created by Levi Eggert on 7/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class TranslationFileManifestParserFactory: IosXmlPullParserFactory {
    
    private let resourcesFileCache: ResourcesSHA256FileCache
    
    init(resourcesFileCache: ResourcesSHA256FileCache) {
        
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
