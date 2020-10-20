//
//  ToolRendererXmlManifest.swift
//  godtools
//
//  Created by Levi Eggert on 10/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ToolRendererXmlManifest: ToolRendererManifestType {
        
    let title: String?
    let pages: [ToolRendererXmlManifestPage]
    let tips: [ToolRendererXmlManifestTip]
    let resources: [ToolRendererXmlManifestResource]
        
    required init(translationManifest: TranslationManifestData) {
           
        let xmlHash: XMLIndexer = SWXMLHash.parse(translationManifest.manifestXmlData)
        
        title = xmlHash["manifest"]["title"]["content:text"].element?.text
        
        pages = (xmlHash["manifest"]["pages"]["page"].all).map {
            ToolRendererXmlManifestPage(page: $0)
        }
        
        tips = (xmlHash["manifest"]["tips"]["tip"].all).map {
            ToolRendererXmlManifestTip(tip: $0)
        }
        
        resources = (xmlHash["manifest"]["resources"]["resource"].all).map {
            ToolRendererXmlManifestResource(resource: $0)
        }
    }
}
