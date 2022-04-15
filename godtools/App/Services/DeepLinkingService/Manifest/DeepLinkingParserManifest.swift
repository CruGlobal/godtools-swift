//
//  DeepLinkingParserManifest.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class DeepLinkingParserManifest {
    
    let urls: [DeepLinkingParserManifestUrl]
    let parserClass: DeepLinkParserType.Type
    
    required init(urls: [DeepLinkingParserManifestUrl], parserClass: DeepLinkParserType.Type) {
        
        self.urls = urls
        self.parserClass = parserClass
    }
}
