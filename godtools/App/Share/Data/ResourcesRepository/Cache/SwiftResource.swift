//
//  SwiftResource.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//


import Foundation
import SwiftData

@available(iOS 17.4, *)
typealias SwiftResource = SwiftResourceV1.SwiftResource

@available(iOS 17.4, *)
enum SwiftResourceV1 {
 
    @Model
    class SwiftResource: IdentifiableSwiftDataObject, ResourceDataModelInterface {
        
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
        var languageIds: [String] = Array()
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
        
        func mapFrom(interface: ResourceDataModelInterface) {
            abbreviation = interface.abbreviation
            attachmentIds = interface.getAttachmentIds()
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
            languageIds = interface.getLanguageIds()
            manifest = interface.manifest
            metatoolId = interface.metatoolId
            name = interface.name
            oneskyProjectId = interface.oneskyProjectId
            resourceDescription = interface.resourceDescription
            resourceType = interface.resourceType
            totalViews = interface.totalViews
            type = interface.type
        }
        
        static func createNewFrom(interface: ResourceDataModelInterface) -> SwiftResource {
            let resource = SwiftResource()
            resource.mapFrom(interface: interface)
            return resource
        }
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
        return languageIds
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
        return Array(latestTranslationIds)
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
        return Array(variantIds)
    }
}
