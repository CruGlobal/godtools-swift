//
//  DownloadedResourceJson.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

class DownloadedResourceJson: GodToolsJSONResource {

    var id = ""
    var name = ""
    var descr = ""
    var abbreviation = ""
    var copyrightDescription = ""
    var bannerId = ""
    var aboutBannerId = ""
    var totalViews = NSNumber(integerLiteral: 0)
    
    var latestTranslations: [TranslationResource]?
    var attachments: [AttachmentResource]?
}

// Mark - JSONResource protocol functions

extension DownloadedResourceJson {
    override func type() -> String {
        return "resource"
    }
    
    func attributeMappings() -> [String : String] {
        return ["descr": "description",
                "bannerId": "attr-banner",
                "aboutBannerId": "attr-banner-about",
                "totalViews": "total-views"]
    }
    
    func includedObjectMappings() -> [String : JSONResource.Type] {
        return ["latestTranslations": TranslationResource.self,
                "attachments": AttachmentResource.self]
    }
}
