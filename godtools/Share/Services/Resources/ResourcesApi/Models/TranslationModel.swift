//
//  TranslationModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct TranslationModel: TranslationModelType, Decodable {
    
    let id: String
    let isPublished: Bool
    let manifestName: String
    let translatedDescription: String
    let translatedName: String
    let translatedTagline: String
    let type: String
    let version: Int
    
    let resource: ResourceModel?
    let language: LanguageModel?
    
    enum RootKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case attributes = "attributes"
        case relationships = "relationships"
    }
    
    enum AttributesKeys: String, CodingKey {
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
        isPublished = try attributesContainer?.decode(Bool.self, forKey: .isPublished) ?? false
        manifestName = try attributesContainer?.decode(String.self, forKey: .manifestName) ?? ""
        translatedDescription = try attributesContainer?.decode(String.self, forKey: .translatedDescription) ?? ""
        translatedName = try attributesContainer?.decode(String.self, forKey: .translatedName) ?? ""
        translatedTagline = try attributesContainer?.decode(String.self, forKey: .translatedTagline) ?? ""
        version = try attributesContainer?.decode(Int.self, forKey: .version) ?? -1
        
        // relationships - resource
        resource = try resourceContainer?.decode(ResourceModel.self, forKey: .data)
        
        // relationships - language
        language = try languageContainer?.decode(LanguageModel.self, forKey: .data)
    }
}
