//
//  RealmResource.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmResource: Object, ResourceModelType {
    
    @objc dynamic var abbreviation: String = ""
    @objc dynamic var attrAboutBannerAnimation: String = ""
    @objc dynamic var attrAboutOverviewVideoYoutube: String = ""
    @objc dynamic var attrBanner: String = ""
    @objc dynamic var attrBannerAbout: String = ""
    @objc dynamic var attrCategory: String = ""
    @objc dynamic var attrDefaultOrder: Int = -1
    @objc dynamic var attrSpotlight: Bool = false
    @objc dynamic var defaultVariantId: String?
    @objc dynamic var id: String = ""
    @objc dynamic var isHidden: Bool = false
    @objc dynamic var manifest: String = ""
    @objc dynamic var metatoolId: String?
    @objc dynamic var name: String = ""
    @objc dynamic var oneskyProjectId: Int = -1
    @objc dynamic var resourceDescription: String = ""
    @objc dynamic var resourceType: String = ""
    @objc dynamic var totalViews: Int = -1
    @objc dynamic var type: String = ""

    let latestTranslationIds = List<String>()
    let attachmentIds = List<String>()
    
    let latestTranslations = List<RealmTranslation>()
    let languages = List<RealmLanguage>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(model: ResourceModel) {
        
        abbreviation = model.abbreviation
        attrAboutBannerAnimation = model.attrAboutBannerAnimation
        attrAboutOverviewVideoYoutube = model.attrAboutOverviewVideoYoutube
        attrBanner = model.attrBanner
        attrBannerAbout = model.attrBannerAbout
        attrCategory = model.attrCategory
        attrDefaultOrder = model.attrDefaultOrder
        attrSpotlight = model.attrSpotlight
        defaultVariantId = model.defaultVariantId
        id = model.id
        isHidden = model.isHidden
        manifest = model.manifest
        metatoolId = model.metatoolId
        name = model.name
        oneskyProjectId = model.oneskyProjectId
        resourceDescription = model.resourceDescription
        resourceType = model.resourceType
        totalViews = model.totalViews
        type = model.type
        
        latestTranslationIds.removeAll()
        latestTranslationIds.append(objectsIn: model.latestTranslationIds)
        
        attachmentIds.removeAll()
        attachmentIds.append(objectsIn: model.attachmentIds)
    }
}
