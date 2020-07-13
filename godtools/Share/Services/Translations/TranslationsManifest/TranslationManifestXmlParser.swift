//
//  TranslationManifestXmlParser.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class TranslationManifestXmlParser: NSObject, TranslationManifestType {
    
    private let xmlHash: XMLIndexer
    private let errorDomain: String
    
    required init(translationManifest: TranslationManifestData) {
        
        xmlHash = SWXMLHash.parse(translationManifest.manifestXmlData)
        errorDomain = String(describing: TranslationManifestXmlParser.self)
        
        super.init()
    }
}
