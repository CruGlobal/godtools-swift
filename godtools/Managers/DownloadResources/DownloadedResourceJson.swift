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
    var abbreviation: String?
    var copyrightDescription: String?
    var bannerId: String?
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
            "abbreviation" : Attribute(),
            "translations" : ToManyRelationship(TranslationResource.self),
            "copyrightDescription": Attribute().serializeAs("attr-copyright"),
            "bannerId": Attribute().serializeAs("attr-banner"),
            "totalViews": Attribute().serializeAs("total-views"),
            "latestTranslations" : ToManyRelationship(TranslationResource.self).serializeAs("latest-translations"),
            "attachments": ToManyRelationship(AttachmentResource.self),
            "pages" : ToManyRelationship(PageResource.self)])
    }
}
