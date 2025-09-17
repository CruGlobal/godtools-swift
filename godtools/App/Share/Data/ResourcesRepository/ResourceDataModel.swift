//
//  ResourceDatainterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct ResourceDataModel: ResourceDataModelInterface {
    
    private let attachmentIds: [String]
    private let languageIds: [String]
    private let latestTranslationIds: [String]
    private let variantIds: [String]
    
    let abbreviation: String
    let attrAboutBannerAnimation: String
    let attrAboutOverviewVideoYoutube: String
    let attrBanner: String
    let attrBannerAbout: String
    let attrCategory: String
    let attrDefaultLocale: String
    let attrDefaultOrder: Int
    let attrSpotlight: Bool
    let defaultVariantId: String?
    let id: String
    let isHidden: Bool
    let manifest: String
    let metatoolId: String?
    let name: String
    let oneskyProjectId: Int
    let resourceDescription: String
    let resourceType: String
    let totalViews: Int
    let type: String
    
    init(interface: ResourceDataModelInterface) {
        
        abbreviation = interface.abbreviation
        attrAboutBannerAnimation = interface.attrAboutBannerAnimation
        attrAboutOverviewVideoYoutube = interface.attrAboutOverviewVideoYoutube
        attrBanner = interface.attrBanner
        attrBannerAbout = interface.attrBannerAbout
        attrCategory = interface.attrCategory
        attrDefaultLocale = interface.attrDefaultLocale
        attrDefaultOrder = interface.attrDefaultOrder
        attrSpotlight = interface.attrSpotlight
        defaultVariantId = interface.defaultVariantId
        id = interface.id
        isHidden = interface.isHidden
        manifest = interface.manifest
        metatoolId = interface.metatoolId
        name = interface.name
        oneskyProjectId = interface.oneskyProjectId
        resourceDescription = interface.resourceDescription
        resourceType = interface.resourceType
        totalViews = interface.totalViews
        type = interface.type
        
        attachmentIds = interface.getAttachmentIds()
        languageIds = interface.getLanguageIds()
        latestTranslationIds = interface.getLatestTranslationIds()
        variantIds = interface.getVariantIds()
    }
    
    func getAttachmentIds() -> [String] {
        return attachmentIds
    }
    
    func getLanguageIds() -> [String] {
        return languageIds
    }
    
    func getLatestTranslationIds() -> [String] {
        return latestTranslationIds
    }
    
    func getVariantIds() -> [String] {
        return variantIds
    }
}

extension ResourceDataModel {
    
    var resourceTypeEnum: ResourceType {
        return ResourceType(rawValue: resourceType) ?? .unknown
    }
    
    var isToolType: Bool {
        return resourceTypeEnum.isToolType
    }
    
    var isLessonType: Bool {
        return resourceTypeEnum.isLessonType
    }
}
