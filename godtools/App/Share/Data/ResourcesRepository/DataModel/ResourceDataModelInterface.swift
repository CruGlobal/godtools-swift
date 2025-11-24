//
//  ResourceDataModelInterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

protocol ResourceDataModelInterface {
    
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
    
    func getAttachmentIds() -> [String]
    func getLanguageIds() -> [String]
    func getLatestTranslationIds() -> [String]
    func getVariantIds() -> [String]
}
