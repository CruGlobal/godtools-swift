//
//  TranslationManifestParserType.swift
//  godtools
//
//  Created by Levi Eggert on 7/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

enum TranslationManifestParserType {
    
    case manifestAndRelatedFiles
    case manifestOnly
    case renderer
    
    var downloadRelatedFilesNeeded: Bool {
        
        switch self {
        
        case .manifestAndRelatedFiles:
            return true
        
        case .manifestOnly:
            return false
       
        case .renderer:
            return true
        }
    }
}
