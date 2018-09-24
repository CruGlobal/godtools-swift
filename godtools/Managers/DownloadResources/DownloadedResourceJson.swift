//
//  DownloadedResourceJson.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SwiftyJSON

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
        return ["description":"descr",
                "attr-banner":"bannerId",
                "attr-banner-about":"aboutBannerId",
                "total-views":"totalViews"]
    }
    
    func includedObjectMappings() -> [String : JSONResource.Type] {
        return ["latestTranslations": TranslationResource.self,
                "attachments": AttachmentResource.self]
    }
}
