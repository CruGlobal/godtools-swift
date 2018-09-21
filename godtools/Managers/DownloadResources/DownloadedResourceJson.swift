//
//  DownloadedResourceJson.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SwiftyJSON

class DownloadedResourceJson: NSObject {

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
    
    required override init() {
        super.init()
    }
}

extension DownloadedResourceJson: JSONResource {
    func type() -> String {
        return "resource"
    }
    
    func attributeMappings() -> [String : String] {
        return ["name":"name",
                "description":"descr",
                "abbreviation":"abbreviation",
                "attr-banner":"bannerId",
                "attr-banner-about":"aboutBannerId",
                "total-views":"totalViews"]
    }
    
    func includedObjectMappings() -> [String : JSONResource.Type] {
        return ["latestTranslations": TranslationResource.self,
                "attachments": AttachmentResource.self]
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        super.setValue(value, forKey: key)
    }
}
