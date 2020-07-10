//
//  TranslationManifestData.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TranslationManifestData {
    
    let translationZipFile: TranslationZipFileModel
    let manifestXmlData: Data
    
    required init(translationZipFile: TranslationZipFileModel, manifestXmlData: Data) {
        
        self.translationZipFile = translationZipFile
        self.manifestXmlData = manifestXmlData
    }
}
