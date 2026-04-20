//
//  ResourceCodable+ToModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/16/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

extension ResourceCodable {
    
    func toModel() -> ResourceDataModel {
        return ResourceDataModel(
            abbreviation: abbreviation,
            attrAboutBannerAnimation: attrAboutBannerAnimation,
            attrAboutOverviewVideoYoutube: attrAboutOverviewVideoYoutube,
            attrBanner: attrBanner,
            attrBannerAbout: attrBannerAbout,
            attrCategory: attrCategory,
            attrDefaultLocale: attrDefaultLocale,
            attrDefaultOrder: attrDefaultOrder,
            attrSpotlight: attrSpotlight,
            defaultVariantId: defaultVariantId,
            id: id,
            isHidden: isHidden,
            manifest: manifest,
            metatoolId: metatoolId,
            name: name,
            oneskyProjectId: oneskyProjectId,
            resourceDescription: resourceDescription,
            resourceType: resourceType,
            totalViews: totalViews,
            type: type,
            attachmentIds: attachmentIds,
            languageIds: languageIds,
            latestTranslationIds: latestTranslationIds,
            variantIds: variantIds
        )
    }
}
