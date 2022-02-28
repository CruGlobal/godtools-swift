//
//  MobileContentRendererLanguageTranslationManifest.swift
//  godtools
//
//  Created by Levi Eggert on 2/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentRendererLanguageTranslationManifest {
    
    let manifest: Manifest
    let language: LanguageModel
    
    required init(manifest: Manifest, language: LanguageModel) {
        
        self.manifest = manifest
        self.language = language
    }
}
