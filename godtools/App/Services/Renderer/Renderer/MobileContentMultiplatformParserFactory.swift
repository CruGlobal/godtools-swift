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
        
    private let translationsFileCache: TranslationsFileCache
    
    required init(translationsFileCache: TranslationsFileCache) {
        
        self.translationsFileCache = translationsFileCache
        
        super.init()
    }
    
    override func openFile(fileName: String) -> Data? {
                
        let location = SHA256FileLocation(sha256WithPathExtension: fileName)
        
        let result = translationsFileCache.getData(location: location)
        
        switch result {
        
        case .success(let data):
            return data
            
        case .failure(let error):
            return nil
        }
    }
}
