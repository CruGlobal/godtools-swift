//
//  SwiftResource.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//


import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftResource = SwiftResourceV1.SwiftResource

@available(iOS 17.4, *)
enum SwiftResourceV1 {
 
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
        var latestTranslationIds: [String] = Array<String>()
        var languageIds: [String] = Array<String>()
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
        
        func mapFrom(model: ResourceDataModel) {
            abbreviation = model.abbreviation
            attachmentIds = model.attachmentIds
            attrAboutBannerAnimation = model.attrAboutBannerAnimation
            attrAboutOverviewVideoYoutube = model.attrAboutOverviewVideoYoutube
            attrBanner = model.attrBanner
            attrBannerAbout = model.attrBannerAbout
            attrCategory = model.attrCategory
            attrDefaultLocale = model.attrDefaultLocale
            attrDefaultOrder = model.attrDefaultOrder
            attrSpotlight = model.attrSpotlight
            defaultVariantId = model.defaultVariantId
            id = model.id
            isHidden = model.isHidden
            languageIds = model.languageIds
            latestTranslationIds = model.latestTranslationIds
            manifest = model.manifest
            metatoolId = model.metatoolId
            name = model.name
            oneskyProjectId = model.oneskyProjectId
            resourceDescription = model.resourceDescription
            resourceType = model.resourceType
            totalViews = model.totalViews
            type = model.type
            variantIds = model.variantIds
        }
        
        static func createNewFrom(model: ResourceDataModel) -> SwiftResource {
            let resource = SwiftResource()
            resource.mapFrom(model: model)
            return resource
        }
    }
}

@available(iOS 17.4, *)
extension SwiftResource {
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
            attachmentIds: getAttachmentIds(),
            languageIds: getLanguageIds(),
            latestTranslationIds: getLatestTranslationIds(),
            variantIds: getVariantIds()
        )
    }
}

// MARK: - Attachments

@available(iOS 17.4, *)
extension SwiftResource {
    
    func getAttachmentIds() -> [String] {
        return attachmentIds
    }
}

// MARK: - Languages

@available(iOS 17.4, *)
extension SwiftResource {
    
    func addLanguage(language: SwiftLanguage) {
        
        if !languages.contains(language) {
            languages.append(language)
            language.resources.append(self)
        }
    }
    
    func getLanguageIds() -> [String] {
        return languages.map({$0.id})
    }
}

// MARK: - Latest Translations

@available(iOS 17.4, *)
extension SwiftResource {
    
    func addLatestTranslation(translation: SwiftTranslation) {
        
        if !latestTranslations.contains(translation) {
            latestTranslations.append(translation)
        }
    }
    
    func getLatestTranslationIds() -> [String] {
        return latestTranslationIds
    }
}

// MARK: - Variants

@available(iOS 17.4, *)
extension SwiftResource {
    
    func getDefaultVariant() -> SwiftResource? {
        return defaultVariant
    }
    
    func setDefaultVariant(variant: SwiftResource?) {
        
        variant?.isVariant = true
        
        defaultVariant = variant
    }
    
    func addVariant(variant: SwiftResource) {
        
        variant.metatool = self
        variant.isVariant = true
        
        if !variants.contains(variant) {
            variants.append(variant)
        }
    }
    
    func getVariantIds() -> [String] {
        return variantIds
    }
}
