//
//  RealmResourceAttributes.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmResourceAttributes: Object, ResourceAttributesType {
    
    @objc dynamic var name: String?
    @objc dynamic var abbreviation: String?
    @objc dynamic var toolDescription: String?
    dynamic var oneskyProjectId: Int?
    dynamic var totalViews: Int?
    @objc dynamic var manifest: String?
    @objc dynamic var resourceType: String?
    @objc dynamic var attrBanner: String?
    @objc dynamic var attrBannerAbout: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case abbreviation = "abbreviation"
        case toolDescription = "description"
        case oneskyProjectId = "onesky-project-id"
        case totalViews = "total-views"
        case manifest = "manifest"
        case resourceType = "resource-type"
        case attrBanner = "attr-banner"
        case attrBannerAbout = "attr-banner-about"
    }
}
