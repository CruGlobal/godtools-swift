//
//  TranslationManifestParserType.swift
//  godtools
//
//  Created by Levi Eggert on 7/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

enum TranslationManifestParserType {
    
    case downloadManifestAndRelatedFiles
    case downloadManifestOnly
    case renderer
    
    var downloadRelatedFilesNeeded: Bool {
        
        switch self {
        
        case .downloadManifestAndRelatedFiles:
            return true
        
        case .downloadManifestOnly:
            return false
       
        case .renderer:
            return true
        }
    }
}
