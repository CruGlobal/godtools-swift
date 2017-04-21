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
    
    var translations: LinkedResourceCollection?
    var pages: LinkedResourceCollection?
    
    override class var resourceType: ResourceType {
        return "resource"
    }
    
    override class var fields: [Field] {
        return fieldsFromDictionary([
            "name" : Attribute(),
            "abbreviation" : Attribute(),
            "translations" : ToManyRelationship(TranslationResource.self),
            "pages" : ToManyRelationship(PageResource.self)])
    }
}
