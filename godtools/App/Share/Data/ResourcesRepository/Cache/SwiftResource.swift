//
//  SwiftResource.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//


import Foundation
import SwiftData

@available(iOS 17, *)
@Model
class SwiftResource: IdentifiableSwiftDataObject {
    
    var abbreviation: String = ""
    var attachmentIds: [String] = Array<String>()
    var attrAboutBannerAnimation: String = ""
    var attrAboutOverviewVideoYoutube: String = ""
    var attrBanner: String = ""
    var attrBannerAbout: String = ""
    var attrCategory: String = ""
    var attrDefaultLocale: String = ""
    var attrDefaultOrder: Int = -1
    var attrSpotlight: Bool = false
    var defaultVariantId: String?
    var isHidden: Bool = false
    var isVariant: Bool = false
    var languageIds: [String] = Array<String>()
    var latestTranslationIds: [String] = Array<String>()
    var manifest: String = ""
    var metatoolId: String?
    var name: String = ""
    var oneskyProjectId: Int = -1
    var resourceDescription: String = ""
    var resourceType: String = ""
    var totalViews: Int = -1
    var type: String = ""
    var variantIds: [String] = Array<String>()
    
    @Attribute(.unique) var id: String = ""

    @Relationship(deleteRule: .nullify) var defaultVariant: SwiftResource?
    @Relationship(deleteRule: .nullify) var metatool: SwiftResource?
    @Relationship(deleteRule: .cascade) var languages: [SwiftLanguage] = Array<SwiftLanguage>()
    @Relationship(deleteRule: .cascade) var latestTranslations: [SwiftTranslation] = Array<SwiftTranslation>()
    @Relationship(deleteRule: .cascade) var variants: [SwiftResource] = Array<SwiftResource>()
        
    init() {
        
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
