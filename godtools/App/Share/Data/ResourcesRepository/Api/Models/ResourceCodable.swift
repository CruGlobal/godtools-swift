//
//  ResourceCodable.swift
//  godtools
//
//  Created by Levi Eggert on 9/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct ResourceCodable: ResourceDataModelInterface, Codable {
    
    let abbreviation: String
    let attachmentIds: [String]
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
    let languageIds: [String]
    let latestTranslationIds: [String]
    let manifest: String
    let metatoolId: String?
    let name: String
    let oneskyProjectId: Int
    let resourceDescription: String
    let resourceType: String
    let totalViews: Int
    let type: String
    let variantIds: [String]
    
    enum RootKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case attributes = "attributes"
        case relationships = "relationships"
    }
    
    enum AttributesKeys: String, CodingKey {
        case abbreviation = "abbreviation"
        case attrAboutBannerAnimation = "attr-about-banner-animation"
        case attrAboutOverviewVideoYoutube = "attr-about-overview-video-youtube"
        case attrBanner = "attr-banner"
        case attrBannerAbout = "attr-banner-about"
        case attrCategory = "attr-category"
        case attrDefaultLocale = "attr-default-locale"
        case attrDefaultOrder = "attr-default-order"
        case attrSpotlight = "attr-spotlight"
        case description = "description"
        case isHidden = "attr-hidden"
        case manifest = "manifest"
        case name = "name"
        case oneskyProjectId = "onesky-project-id"
        case resourceType = "resource-type"
        case totalViews = "total-views"
    }
    
    enum RelationshipsKeys: String, CodingKey {
        case attachments = "attachments"
        case defaultVariant = "default-variant"
        case latestTranslations = "latest-translations"
        case metatool = "metatool"
        case variants = "variants"
    }
    
    enum DataCodingKeys: String, CodingKey {
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        
        var attributesContainer: KeyedDecodingContainer<AttributesKeys>?
        var relationshipsContainer: KeyedDecodingContainer<RelationshipsKeys>?
        var latestTranslationsContainer: KeyedDecodingContainer<DataCodingKeys>?
        var attachmentsContainer: KeyedDecodingContainer<DataCodingKeys>?
        
        do {
            attributesContainer = try container.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
            relationshipsContainer = try container.nestedContainer(keyedBy: RelationshipsKeys.self, forKey: .relationships)
            latestTranslationsContainer = try relationshipsContainer?.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .latestTranslations)
            attachmentsContainer = try relationshipsContainer?.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .attachments)
        }
        catch {

        }
        
        // attributes
        abbreviation = try attributesContainer?.decodeIfPresent(String.self, forKey: .abbreviation) ?? ""
        attrAboutBannerAnimation = try attributesContainer?.decodeIfPresent(String.self, forKey: .attrAboutBannerAnimation) ?? ""
        attrAboutOverviewVideoYoutube = try attributesContainer?.decodeIfPresent(String.self, forKey: .attrAboutOverviewVideoYoutube) ?? ""
        attrBanner = try attributesContainer?.decodeIfPresent(String.self, forKey: .attrBanner) ?? ""
        attrBannerAbout = try attributesContainer?.decodeIfPresent(String.self, forKey: .attrBannerAbout) ?? ""
        attrCategory = try attributesContainer?.decodeIfPresent(String.self, forKey: .attrCategory) ?? ""
        let attrSpotlightString: String = try attributesContainer?.decodeIfPresent(String.self, forKey: .attrSpotlight) ?? "false"
        attrSpotlight = attrSpotlightString == "true" ? true : false
        attrDefaultLocale = try attributesContainer?.decodeIfPresent(String.self, forKey: .attrDefaultLocale) ?? "en"
        let attrDefaultOrderString: String? = try attributesContainer?.decodeIfPresent(String.self, forKey: .attrDefaultOrder) ?? ""
        if let attrDefaultOrderString = attrDefaultOrderString, let attrDefaultOrderIntValue = Int(attrDefaultOrderString) {
            attrDefaultOrder = attrDefaultOrderIntValue
        }
        else {
            attrDefaultOrder = -1
        }
        let isHiddenString: String = try attributesContainer?.decodeIfPresent(String.self, forKey: .isHidden) ?? "false"
        isHidden = isHiddenString == "true" ? true : false
        manifest = try attributesContainer?.decodeIfPresent(String.self, forKey: .manifest) ?? ""
        name = try attributesContainer?.decodeIfPresent(String.self, forKey: .name) ?? ""
        oneskyProjectId = try attributesContainer?.decodeIfPresent(Int.self, forKey: .oneskyProjectId) ?? -1
        resourceDescription = try attributesContainer?.decodeIfPresent(String.self, forKey: .description) ?? ""
        resourceType = try attributesContainer?.decodeIfPresent(String.self, forKey: .resourceType) ?? ""
        totalViews = try attributesContainer?.decodeIfPresent(Int.self, forKey: .totalViews) ?? -1
                
        // relationships
        let latestTranslations: [TranslationCodable] = try latestTranslationsContainer?.decodeIfPresent([TranslationCodable].self, forKey: .data) ?? []
        latestTranslationIds = latestTranslations.map({$0.id})
        
        let attachments: [AttachmentCodable] = try attachmentsContainer?.decodeIfPresent([AttachmentCodable].self, forKey: .data) ?? []
        attachmentIds = attachments.map({$0.id})
        
        do {
            let metatool = try relationshipsContainer?.decodeIfPresent(ScriptJsonApiResponseDataObject<ScriptJsonApiResponseBaseData>.self, forKey: .metatool)
            metatoolId = metatool?.dataObject.id
        }
        catch {
            metatoolId = nil
        }
        
        do {
            let defaultVariant = try relationshipsContainer?.decodeIfPresent(ScriptJsonApiResponseDataObject<ScriptJsonApiResponseBaseData>.self, forKey: .defaultVariant)
            defaultVariantId = defaultVariant?.dataObject.id
        }
        catch {
            defaultVariantId = nil
        }
        
        do {
            let variants = try relationshipsContainer?.decodeIfPresent(ScriptJsonApiResponseDataArray<ScriptJsonApiResponseBaseData>.self, forKey: .variants)?.dataArray ?? []
            variantIds = variants.map({$0.id})
        }
        catch {
            variantIds = []
        }
        
        // set when initialized from a model.
        languageIds = Array()
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

extension ResourceCodable: Equatable {
    static func == (this: ResourceCodable, that: ResourceCodable) -> Bool {
        return this.id == that.id
    }
}
