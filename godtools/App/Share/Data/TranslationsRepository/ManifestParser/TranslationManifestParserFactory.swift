//
//  TranslationManifestParserFactory.swift
//  godtools
//
//  Created by Levi Eggert on 7/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsShared

final class TranslationManifestParserFactory: IosXmlPullParserFactory {
    
    private let resourcesFileCache: ResourcesFileCache
    
    init(resourcesFileCache: ResourcesFileCache) {
        
        self.resourcesFileCache = resourcesFileCache
        
        super.init()
    }
    
    override func openFile(fileName: String) async throws -> Data? {
                
        let location = FileCacheLocation(relativeUrlString: fileName)
                
        return try await resourcesFileCache.cache.getData(location: location)
    }
}
