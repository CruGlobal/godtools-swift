//
//  MobileContentMultiplatformParser.swift
//  godtools
//
//  Created by Levi Eggert on 7/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentMultiplatformParser {
    
    private let resultData: Result.Data?
    
    required init(manifestFilename: String, sha256FileCache: ResourcesSHA256FileCache) {
                        
        let manifestParser = IosManifestParser(parserFactory: MobileContentMultiplatformParserFactory(sha256FileCache: sha256FileCache))
        
        let result = manifestParser.parseManifestBlocking(fileName: manifestFilename)
        
        if let resultData = result as? Result.Data {
            
            print("page count: \(resultData.manifest.tractPages.count)")
            self.resultData = resultData
            
            let manifest: Manifest = resultData.manifest
            
            let backgroundResource: Resource? = manifest.backgroundImage
            
            let tractPage: TractPage = manifest.tractPages[0]
            
            let lessonPage: LessonPage = manifest.lessonPages[0]
            
            let card: Card = tractPage.cards[0]
            
            let content: Content = card.content[0]
        }
        else {
            self.resultData = nil
        }
    }
}

extension MobileContentMultiplatformParser {
    
}
