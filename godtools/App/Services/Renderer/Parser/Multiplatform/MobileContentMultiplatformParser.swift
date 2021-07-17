//
//  MobileContentMultiplatformParser.swift
//  godtools
//
//  Created by Levi Eggert on 7/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentMultiplatformParser: MobileContentParserType {
    
    let manifest: MobileContentManifestType
    var pageModels: [PageModelType] = Array()
    var errors: [Error] = Array()
    
    required init(translationManifestData: TranslationManifestData, translationsFileCache: TranslationsFileCache) {
        fatalError("not yet implemented")
    }
    
    required init(manifest: MobileContentManifestType, pageNodes: [PageNode]) {
        fatalError("not yet implemented")
    }
    
    func getPageForListenerEvents(events: [String]) -> Int? {
        return nil
    }
    
    required init?(manifestFilename: String, sha256FileCache: ResourcesSHA256FileCache) {
                        
        let manifestParser = IosManifestParser(parserFactory: MobileContentMultiplatformParserFactory(sha256FileCache: sha256FileCache))
        
        let result = manifestParser.parseManifestBlocking(fileName: manifestFilename)
        
        guard let resultData = result as? Result.Data else {
            return nil
        }

        self.manifest = MultiplatformManifest(manifest: resultData.manifest)
        
        print("DONE")
    }
}
