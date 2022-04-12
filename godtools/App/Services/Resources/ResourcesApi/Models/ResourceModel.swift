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
    let attrAboutOverviewVideoYoutube: String
    let attrBanner: String
    let attrBannerAbout: String
    let attrCategory: String
    let attrDefaultOrder: Int
    let id: String
    let isHidden: Bool
    let manifest: String
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
        case attrAboutOverviewVideoYoutube = "attr-about-overview-video-youtube"
        case attrBanner = "attr-banner"
        case attrBannerAbout = "attr-banner-about"
        case attrCategory = "attr-category"
        case attrDefaultOrder = "attr-default-order"
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
        case latestTranslations = "latest-translations"
    }
    
    enum DataCodingKeys: String, CodingKey {
        case data = "data"
    }
    
    init(realmResource: RealmResource) {
        
        abbreviation = realmResource.abbreviation
        attrAboutOverviewVideoYoutube = realmResource.attrAboutOverviewVideoYoutube
        attrBanner = realmResource.attrBanner
        attrBannerAbout = realmResource.attrBannerAbout
        attrCategory = realmResource.attrCategory
        attrDefaultOrder = realmResource.attrDefaultOrder
        id = realmResource.id
        isHidden = realmResource.isHidden
        manifest = realmResource.manifest
        name = realmResource.name
        oneskyProjectId = realmResource.oneskyProjectId
        resourceDescription = realmResource.resourceDescription
        resourceType = realmResource.resourceType
        totalViews = realmResource.totalViews
        type = realmResource.type
        
        latestTranslationIds = Array(realmResource.latestTranslationIds)
        attachmentIds = Array(realmResource.attachmentIds)
        languageIds = Array(realmResource.languages).map({$0.id})
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
        attrAboutOverviewVideoYoutube = try attributesContainer?.decodeIfPresent(String.self, forKey: .attrAboutOverviewVideoYoutube) ?? ""
        attrBanner = try attributesContainer?.decodeIfPresent(String.self, forKey: .attrBanner) ?? ""
        attrBannerAbout = try attributesContainer?.decodeIfPresent(String.self, forKey: .attrBannerAbout) ?? ""
        attrCategory = try attributesContainer?.decodeIfPresent(String.self, forKey: .attrCategory) ?? ""
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
        
        // set when initialized from a RealmResource.
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
    
    func supportsLanguage(languageId: String) -> Bool {
        if !languageId.isEmpty {
            return languageIds.contains(languageId)
        }
        return false
    }
}
