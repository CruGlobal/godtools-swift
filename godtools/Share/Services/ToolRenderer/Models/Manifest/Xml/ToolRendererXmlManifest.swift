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
      
    let attributes: ToolRendererXmlManifestAttributes
    let title: String?
    let pages: [ToolRendererXmlManifestPage]
    let tips: [TipId: ToolRendererXmlManifestTip]
    let resources: [ResourceFilename: ToolRendererXmlManifestResource]
        
    required init(translationManifest: TranslationManifestData) {
           
        let xmlHash: XMLIndexer = SWXMLHash.parse(translationManifest.manifestXmlData)
        
        let manifest: XMLIndexer = xmlHash["manifest"]

        attributes = ToolRendererXmlManifestAttributes(manifest: manifest)
        
        title = xmlHash["manifest"]["title"]["content:text"].element?.text
        
        let pagesIndexer: [XMLIndexer] = manifest["pages"]["page"].all
        pages = (pagesIndexer).map {
            ToolRendererXmlManifestPage(page: $0)
        }
        
        let tipsIndexer: [XMLIndexer] = manifest["tips"]["tip"].all
        var tipsDictionary: [TipId: ToolRendererManifestTip] = Dictionary()
        
        for tipXml in tipsIndexer {
            let tip = ToolRendererManifestTip(tip: tipXml)
            tipsDictionary[tip.id] = tip
        }
        
        self.tips = tipsDictionary
        
        let resourcesIndexer: [XMLIndexer] = manifest["resources"]["resource"].all
        var resourcesDictionary: [ResourceFilename: ToolRendererXmlManifestResource] = Dictionary()
        
        for resourceXml in resourcesIndexer {
            let resource = ToolRendererXmlManifestResource(resource: resourceXml)
            resourcesDictionary[resource.filename] = resource
        }
        
        self.resources = resourcesDictionary        
    }
}
