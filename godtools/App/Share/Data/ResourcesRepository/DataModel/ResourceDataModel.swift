//
//  ResourceDatainterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct ResourceDataModel {
    
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
    let attachmentIds: [String]
    let languageIds: [String]
    let latestTranslationIds: [String]
    let variantIds: [String]
}

extension ResourceDataModel: Equatable {
    static func == (this: ResourceDataModel, that: ResourceDataModel) -> Bool {
        return this.id == that.id
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
