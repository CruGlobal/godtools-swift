//
//  TranslationManifestParserType.swift
//  godtools
//
//  Created by Levi Eggert on 7/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

enum TranslationManifestParserType {
    
    case related
    case renderer
    case tips(parsesRelatedFiles: Bool)
    
    var parsesRelatedFiles: Bool {
        
        switch self {
        case .related:
            return true
        case .renderer:
            return true
        case .tips(let parsesRelatedFiles):
            return parsesRelatedFiles
        }
    }
}
