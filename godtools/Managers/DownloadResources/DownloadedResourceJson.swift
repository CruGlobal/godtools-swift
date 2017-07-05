//
//  DownloadedResourceJson.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import Spine

class DownloadedResourceJson: Resource {
    
    var name: String?
    var descr: String?
    var abbreviation: String?
    var copyrightDescription: String?
    var bannerId: String?
    var aboutBannerId: String?
    var totalViews: NSNumber?
    
    var latestTranslations: LinkedResourceCollection?
    var translations: LinkedResourceCollection?
    var pages: LinkedResourceCollection?
    var attachments: LinkedResourceCollection?
    
    override class var resourceType: ResourceType {
        return "resource"
    }
    
    override class var fields: [Field] {
        return fieldsFromDictionary([
            "name" : Attribute(),
            "descr": Attribute().serializeAs("description"),
            "abbreviation" : Attribute(),
            "translations" : ToManyRelationship(TranslationResource.self),
            "copyrightDescription": Attribute().serializeAs("attr-copyright"),
            "bannerId": Attribute().serializeAs("attr-banner"),
            "aboutBannerId": Attribute().serializeAs("attr-banner-about"),
            "totalViews": Attribute().serializeAs("total-views"),
            "latestTranslations" : ToManyRelationship(TranslationResource.self).serializeAs("latest-translations"),
            "attachments": ToManyRelationship(AttachmentResource.self)])
    }
}
