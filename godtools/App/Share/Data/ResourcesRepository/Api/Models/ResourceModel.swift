//
//  ResourceModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ResourceModel: ResourceModelType, Decodable, Identifiable {
    
    let abbreviation: String
    let attrAboutBannerAnimation: String
    let attrAboutOverviewVideoYoutube: String
    let attrBanner: String
    let attrBannerAbout: String
    let attrCategory: String
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
    
    let latestTranslationIds: [String]
    let attachmentIds: [String]
    let languageIds: [String]
    
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
    }
    
    enum DataCodingKeys: String, CodingKey {
        case data = "data"
    }
    
    init(model: ResourceModelType) {
        
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
        manifest = model.manifest
        metatoolId = model.metatoolId
        name = model.name
        oneskyProjectId = model.oneskyProjectId
        resourceDescription = model.resourceDescription
        resourceType = model.resourceType
        totalViews = model.totalViews
        type = model.type
        
        latestTranslationIds = model.getLatestTranslationIds()
        attachmentIds = model.getAttachmentIds()
        languageIds = model.getLanguageIds()
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
                
        // relationships - latest-translations
        let latestTranslations: [TranslationModel] = try latestTranslationsContainer?.decodeIfPresent([TranslationModel].self, forKey: .data) ?? []
        latestTranslationIds = latestTranslations.map({$0.id})
        
        // relationships - attachments
        let attachments: [AttachmentModel] = try attachmentsContainer?.decodeIfPresent([AttachmentModel].self, forKey: .data) ?? []
        attachmentIds = attachments.map({$0.id})
        
        // relationships - metatool
        
        let metatoolData: ResourceModelMetatoolData?

        do {
            let metatoolContainer: KeyedDecodingContainer<DataCodingKeys>? = try relationshipsContainer?.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .metatool)
            metatoolData = try metatoolContainer?.decodeIfPresent(ResourceModelMetatoolData.self, forKey: .data)
        }
        catch {
            metatoolData = nil
        }
        
        metatoolId = metatoolData?.id
        
        // relationships - default variant
        
        let defaultVariantData: ResourceModelDefaultVariantData?
        
        do {
            let defaultVariantContainer = try relationshipsContainer?.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .defaultVariant)
            defaultVariantData = try defaultVariantContainer?.decodeIfPresent(ResourceModelDefaultVariantData.self, forKey: .data)
        }
        catch {
            defaultVariantData = nil
        }
        
        defaultVariantId = defaultVariantData?.id
        
        // set when initialized from a model.
        languageIds = Array()
    }
}

extension ResourceModel: Equatable {
    static func ==(lhs: ResourceModel, rhs: ResourceModel) -> Bool {
        return lhs.id == rhs.id
    }
}

extension ResourceModel {
    
    var resourceTypeEnum: ResourceType {
        return ResourceType(rawValue: resourceType) ?? .unknown
    }
    
    var isToolType: Bool {
        return resourceTypeEnum.isToolType
    }
    
    var isLessonType: Bool {
        return resourceTypeEnum.isLessonType
    }
    
    func getLatestTranslationIds() -> [String] {
        return latestTranslationIds
    }
    
    func getAttachmentIds() -> [String] {
        return attachmentIds
    }
    
    func getLanguageIds() -> [String] {
        return languageIds
    }
    
    func supportsLanguage(languageId: String) -> Bool {
        if !languageId.isEmpty {
            return languageIds.contains(languageId)
        }
        return false
    }
}
