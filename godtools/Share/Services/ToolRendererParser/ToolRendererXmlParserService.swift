//
//  ToolRendererXmlParserService.swift
//  godtools
//
//  Created by Levi Eggert on 10/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ToolRendererXmlParserService: ToolRendererParserServiceType {
    
    let manifest: ToolRendererXmlManifest
    
    required init(translationManifest: TranslationManifestData) {
        
        manifest = ToolRendererXmlManifest(translationManifest: translationManifest)
    }
}
