//
//  MobileContentXmlManifest.swift
//  godtools
//
//  Created by Levi Eggert on 10/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class MobileContentXmlManifest: MobileContentManifestType {
      
    private let resources: [String: MobileContentManifestResourceType]
    
    let attributes: MobileContentManifestAttributesType
    let title: String?
    let pages: [MobileContentManifestPageType]
    let tips: [TipId: MobileContentManifestTipType]
        
    required init(translationManifestData: TranslationManifestData) {
           
        let xmlHash: XMLIndexer = SWXMLHash.parse(translationManifestData.manifestXmlData)
        
        let manifest: XMLIndexer = xmlHash["manifest"]

        attributes = MobileContentXmlManifestAttributes(manifest: manifest)
        
        title = xmlHash["manifest"]["title"]["content:text"].element?.text
        
        let pagesIndexer: [XMLIndexer] = manifest["pages"]["page"].all
        pages = (pagesIndexer).map {
            MobileContentXmlManifestPage(page: $0)
        }
        
        let tipsIndexer: [XMLIndexer] = manifest["tips"]["tip"].all
        var tipsDictionary: [TipId: MobileContentManifestTipType] = Dictionary()
        
        for tipXml in tipsIndexer {
            let tip = MobileContentXmlManifestTip(tip: tipXml)
            tipsDictionary[tip.id] = tip
        }
        
        self.tips = tipsDictionary
        
        let resourcesIndexer: [XMLIndexer] = manifest["resources"]["resource"].all
        var resourcesDictionary: [String: MobileContentXmlManifestResource] = Dictionary()
        
        for resourceXml in resourcesIndexer {
            let resource = MobileContentXmlManifestResource(resource: resourceXml)
            resourcesDictionary[resource.filename] = resource
        }
        
        self.resources = resourcesDictionary        
    }
    
    func getResource(fileName: String) -> MobileContentManifestResourceType? {
        
        return resources[fileName]
    }
}
