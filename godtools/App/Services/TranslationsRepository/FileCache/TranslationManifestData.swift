//
//  TranslationManifestData.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

// TODO: Remove in GT-1448. ~Levi
class TranslationManifestData {
    
    let translationZipFile: TranslationZipFileModel
    let manifestXmlData: Data
    
    required init(translationZipFile: TranslationZipFileModel, manifestXmlData: Data) {
        
        self.translationZipFile = translationZipFile
        self.manifestXmlData = manifestXmlData
    }
}
