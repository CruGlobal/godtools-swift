//
//  RendererXmlManifest.swift
//  godtools
//
//  Created by Levi Eggert on 10/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class RendererXmlManifest: RendererManifestType {
      
    let attributes: RendererXmlManifestAttributes
    let title: String?
    let pages: [RendererXmlManifestPage]
    let tips: [TipId: RendererXmlManifestTip]
    let resources: [ResourceFilename: RendererXmlManifestResource]
        
    required init(translationManifest: TranslationManifestData) {
           
        let xmlHash: XMLIndexer = SWXMLHash.parse(translationManifest.manifestXmlData)
        
        let manifest: XMLIndexer = xmlHash["manifest"]

        attributes = RendererXmlManifestAttributes(manifest: manifest)
        
        title = xmlHash["manifest"]["title"]["content:text"].element?.text
        
        let pagesIndexer: [XMLIndexer] = manifest["pages"]["page"].all
        pages = (pagesIndexer).map {
            RendererXmlManifestPage(page: $0)
        }
        
        let tipsIndexer: [XMLIndexer] = manifest["tips"]["tip"].all
        var tipsDictionary: [TipId: RendererManifestTip] = Dictionary()
        
        for tipXml in tipsIndexer {
            let tip = RendererManifestTip(tip: tipXml)
            tipsDictionary[tip.id] = tip
        }
        
        self.tips = tipsDictionary
        
        let resourcesIndexer: [XMLIndexer] = manifest["resources"]["resource"].all
        var resourcesDictionary: [ResourceFilename: RendererXmlManifestResource] = Dictionary()
        
        for resourceXml in resourcesIndexer {
            let resource = RendererXmlManifestResource(resource: resourceXml)
            resourcesDictionary[resource.filename] = resource
        }
        
        self.resources = resourcesDictionary        
    }
}
