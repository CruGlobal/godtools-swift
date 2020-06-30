//
//  DownloadedResourceJson.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

class DownloadedResourceJson: GodToolsJSONResource {

    @objc var id = ""
    @objc var name = ""
    @objc var descr = ""
    @objc var abbreviation = ""
    @objc var copyrightDescription = ""
    @objc var bannerId = ""
    @objc var aboutBannerId = ""
    @objc var toolType = ""
    @objc var totalViews = NSNumber(integerLiteral: 0)
    @objc var aboutOverviewVideoYouTube: String = ""
    
    @objc var latestTranslations: [TranslationResource]?
    @objc var attachments: [AttachmentResource]?
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
                "catrgory": "attr-category",
                "totalViews": "total-views",
                "toolType": "resource-type",
                "aboutOverviewVideoYouTube": "attr-about-overview-video-youtube"
        ]
    }
    
    func includedObjectMappings() -> [String : JSONResource.Type] {
        return ["latestTranslations": TranslationResource.self,
                "attachments": AttachmentResource.self]
    }
}
