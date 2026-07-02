//
//  TranslationFile.swift
//  godtools
//
//  Created by Levi Eggert on 5/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import GodToolsShared

enum TranslationFile {
    
    case manifestFile(manifestFile: ManifestFile)
    case translationManifest(translation: TranslationDataModel)
    
    var fileName: String {
        get throws {
            switch self {
            case .manifestFile(let manifestFile):
                return try manifestFile.fileName
            case .translationManifest(let translation):
                return translation.manifestName
            }
        }
    }
}
