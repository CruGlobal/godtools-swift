//
//  DownloadedResourceJson.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SwiftyJSON

class DownloadedResourceJson: JSONResource {
    
    override class var type: String {
        return "resource"
    }
    
    override class var attributeMappings: [String: String] {
        return ["name":"name",
                "description":"descr",
                "abbreviation":"abbreviation",
                "copyrightDescription":"copyrightDescription",
                "attr-banner":"bannerId",
                "attr-banner-about":"aboutBannerId",
                "total-views":"totalViews"]
    }
    
    override class var includedObjectMappings: [String: JSONResource.Type] {
        return ["latestTranslations": TranslationResource.self,
                "attachments": AttachmentResource.self]
    }

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
