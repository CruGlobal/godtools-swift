//
//  TranslationCodable.swift
//  godtools
//
//  Created by Levi Eggert on 9/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct TranslationCodable: TranslationDataModelInterface, Codable {
    
    let id: String
    let isPublished: Bool
    let language: LanguageCodable?
    let manifestName: String
    let resource: ResourceCodable?
    let toolDetailsBibleReferences: String
    let toolDetailsConversationStarters: String
    let toolDetailsOutline: String
    let translatedDescription: String
    let translatedName: String
    let translatedTagline: String
    let type: String
    let version: Int
    
    enum RootKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case attributes = "attributes"
        case relationships = "relationships"
    }
    
    enum AttributesKeys: String, CodingKey {
        case attrToolDetailsBibleReferences = "attr-tool-details-bible-references"
        case attrToolDetailsConversationStarters = "attr-tool-details-conversation-starters"
        case attrToolDetailsOutline = "attr-tool-details-outline"
        case isPublished = "is-published"
        case manifestName = "manifest-name"
        case translatedDescription = "translated-description"
        case translatedName = "translated-name"
        case translatedTagline = "translated-tagline"
        case version = "version"
    }
    
    enum RelationshipsKeys: String, CodingKey {
        case resource = "resource"
        case language = "language"
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
        var resourceContainer: KeyedDecodingContainer<DataCodingKeys>?
        var languageContainer: KeyedDecodingContainer<DataCodingKeys>?
        
        do {
            attributesContainer = try container.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
            relationshipsContainer = try container.nestedContainer(keyedBy: RelationshipsKeys.self, forKey: .relationships)
            resourceContainer = try relationshipsContainer?.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .resource)
            languageContainer = try relationshipsContainer?.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .language)
        }
        catch {
            // It's possible a Translation doesn't have keys for attributes and relationships.
        }

        // attributes
        isPublished = try attributesContainer?.decodeIfPresent(Bool.self, forKey: .isPublished) ?? false
        manifestName = try attributesContainer?.decodeIfPresent(String.self, forKey: .manifestName) ?? ""
        toolDetailsBibleReferences = try attributesContainer?.decodeIfPresent(String.self, forKey: .attrToolDetailsBibleReferences) ?? ""
        toolDetailsConversationStarters = try attributesContainer?.decodeIfPresent(String.self, forKey: .attrToolDetailsConversationStarters) ?? ""
        toolDetailsOutline = try attributesContainer?.decodeIfPresent(String.self, forKey: .attrToolDetailsOutline) ?? ""
        translatedDescription = try attributesContainer?.decodeIfPresent(String.self, forKey: .translatedDescription) ?? ""
        translatedName = try attributesContainer?.decodeIfPresent(String.self, forKey: .translatedName) ?? ""
        translatedTagline = try attributesContainer?.decodeIfPresent(String.self, forKey: .translatedTagline) ?? ""
        version = try attributesContainer?.decodeIfPresent(Int.self, forKey: .version) ?? -1
        
        // relationships - resource
        resource = try resourceContainer?.decodeIfPresent(ResourceCodable.self, forKey: .data)
                
        // relationships - language
        language = try languageContainer?.decodeIfPresent(LanguageCodable.self, forKey: .data)
    }
}

extension TranslationCodable {
    
    var resourceDataModel: ResourceDataModel? {
        
        guard let resource = resource else {
            return nil
        }
        
        return ResourceDataModel(interface: resource)
    }
    
    var languageDataModel: LanguageDataModel? {
        
        guard let language = language else {
            return nil
        }
        
        return LanguageDataModel(interface: language)
    }
}
