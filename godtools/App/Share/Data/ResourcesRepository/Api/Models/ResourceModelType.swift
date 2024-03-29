//
//  ResourceModelType.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ResourceModelType {
        
    var abbreviation: String { get }
    var attrAboutBannerAnimation: String { get }
    var attrAboutOverviewVideoYoutube: String { get }
    var attrBanner: String { get }
    var attrBannerAbout: String { get }
    var attrCategory: String { get }
    var attrDefaultLocale: String { get }
    var attrDefaultOrder: Int { get }
    var attrSpotlight: Bool { get }
    var defaultVariantId: String? { get }
    var id: String { get }
    var isHidden: Bool { get }
    var manifest: String { get }
    var metatoolId: String? { get }
    var name: String { get }
    var oneskyProjectId: Int { get }
    var resourceDescription: String { get }
    var resourceType: String { get }
    var totalViews: Int { get }
    var type: String { get }
        
    func getLatestTranslationIds() -> [String]
    func getAttachmentIds() -> [String]
    func getLanguageIds() -> [String]
    func getVariantIds() -> [String]
}
