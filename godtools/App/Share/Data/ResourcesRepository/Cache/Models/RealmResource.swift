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
    @objc dynamic var isVariant: Bool = false
    @objc dynamic var manifest: String = ""
    @objc dynamic var metatoolId: String?
    @objc dynamic var name: String = ""
    @objc dynamic var oneskyProjectId: Int = -1
    @objc dynamic var resourceDescription: String = ""
    @objc dynamic var resourceType: String = ""
    @objc dynamic var totalViews: Int = -1
    @objc dynamic var type: String = ""

    // relationships
    
    @objc dynamic private var defaultVariant: RealmResource?
    @objc dynamic private var metatool: RealmResource?
    
    private let attachmentIds = List<String>()
    private let languages = List<RealmLanguage>()
    private let latestTranslationIds = List<String>()
    private let latestTranslations = List<RealmTranslation>()
    private let variantIds = List<String>()
    private let variants = List<RealmResource>()
    
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
        isVariant = !(model.metatoolId ?? "").isEmpty
        manifest = model.manifest
        metatoolId = model.metatoolId
        name = model.name
        oneskyProjectId = model.oneskyProjectId
        resourceDescription = model.resourceDescription
        resourceType = model.resourceType
        totalViews = model.totalViews
        type = model.type
        
        latestTranslationIds.removeAll()
        latestTranslationIds.append(objectsIn: model.getLatestTranslationIds())
        
        attachmentIds.removeAll()
        attachmentIds.append(objectsIn: model.getAttachmentIds())
        
        variantIds.removeAll()
        variantIds.append(objectsIn: model.getVariantIds())
    }
}

// MARK: - Attachments

extension RealmResource {
    
    func getAttachmentIds() -> [String] {
        return Array(attachmentIds)
    }
}

// MARK: - Languages

extension RealmResource {
    
    func addLanguage(language: RealmLanguage) {
        
        if !languages.contains(language) {
            languages.append(language)
        }
    }
    
    func getLanguageIds() -> [String] {
        return languages.map({$0.id})
    }
    
    func getLanguages() -> List<RealmLanguage> {
        return languages
    }
}

// MARK: - Latest Translations

extension RealmResource {
    
    func addLatestTranslation(translation: RealmTranslation) {
        
        if !latestTranslations.contains(translation) {
            latestTranslations.append(translation)
        }
    }
    
    func getLatestTranslationIds() -> [String] {
        return Array(latestTranslationIds)
    }
    
    func getLatestTranslations() -> List<RealmTranslation> {
        return latestTranslations
    }
}

// MARK: - Variants

extension RealmResource {
    
    func getDefaultVariant() -> RealmResource? {
        return defaultVariant
    }
    
    func setDefaultVariant(variant: RealmResource) {
        
        variant.isVariant = true
        
        defaultVariant = variant
    }
    
    func addVariant(variant: RealmResource) {
        
        variant.metatool = self
        variant.isVariant = true
        
        if !variants.contains(variant) {
            variants.append(variant)
        }
    }
    
    func getVariantIds() -> [String] {
        return Array(variantIds)
    }
    
    func getVariants() -> List<RealmResource> {
        return variants
    }
}
