//
//  ResourceCodable+Random.swift
//  godtools
//
//  Created by Levi Eggert on 7/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools

extension ResourceCodable {

    static func random(
        id: String = UUID().uuidString,
        abbreviation: String = String.random(),
        attachmentIds: [String] = Array(),
        attrAboutBannerAnimation: String = String.random(),
        attrAboutOverviewVideoYoutube: String = String.random(),
        attrBanner: String = String.random(),
        attrBannerAbout: String = String.random(),
        attrCategory: String = String.random(),
        attrDefaultLocale: String = LanguageCodeDomainModel.english.rawValue,
        attrDefaultOrder: Int = Int.random(),
        attrSpotlight: Bool = Bool.random(),
        defaultVariantId: String? = nil,
        isHidden: Bool = Bool.random(),
        languageIds: [String] = Array(),
        latestTranslationIds: [String] = Array(),
        manifest: String = String.random(),
        metatoolId: String? = nil,
        name: String = String.random(),
        oneskyProjectId: Int = Int.random(),
        resourceDefaultOrders: [ResourceDefaultOrderCodable] = Array(),
        resourceDescription: String = String.random(),
        resourceScores: [ResourceScoreCodable] = Array(),
        resourceType: String = ResourceType.tract.rawValue,
        totalViews: Int = Int.random(),
        type: String = String.random(),
        variantIds: [String] = Array()
    ) -> ResourceCodable {

        return ResourceCodable(
            id: id,
            abbreviation: abbreviation,
            attachmentIds: attachmentIds,
            attrAboutBannerAnimation: attrAboutBannerAnimation,
            attrAboutOverviewVideoYoutube: attrAboutOverviewVideoYoutube,
            attrBanner: attrBanner,
            attrBannerAbout: attrBannerAbout,
            attrCategory: attrCategory,
            attrDefaultLocale: attrDefaultLocale,
            attrDefaultOrder: attrDefaultOrder,
            attrSpotlight: attrSpotlight,
            defaultVariantId: defaultVariantId,
            isHidden: isHidden,
            languageIds: languageIds,
            latestTranslationIds: latestTranslationIds,
            manifest: manifest,
            metatoolId: metatoolId,
            name: name,
            oneskyProjectId: oneskyProjectId,
            resourceDefaultOrders: resourceDefaultOrders,
            resourceDescription: resourceDescription,
            resourceScores: resourceScores,
            resourceType: resourceType,
            totalViews: totalViews,
            type: type,
            variantIds: variantIds
        )
    }
}
