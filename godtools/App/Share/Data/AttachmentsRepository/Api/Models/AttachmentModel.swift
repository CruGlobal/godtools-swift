//
//  AttachmentModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct AttachmentModel: AttachmentModelType, Decodable {
    
    let file: String
    let fileFilename: String
    let id: String
    let isZipped: Bool
    let sha256: String
    let type: String
    
    let resource: ResourceModel?
    
    enum RootKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case attributes = "attributes"
        case relationships = "relationships"
    }
    
    enum AttributesKeys: String, CodingKey {
        case file = "file"
        case fileFilename = "file-file-name"
        case isZipped = "is-zipped"
        case sha256 = "sha256"
    }
    
    enum RelationshipsKeys: String, CodingKey {
        case resource = "resource"
    }
    
    enum DataCodingKeys: String, CodingKey {
        case data = "data"
    }
    
    init(realmAttachment: RealmAttachment) {
        
        file = realmAttachment.file
        fileFilename = realmAttachment.fileFilename
        id = realmAttachment.id
        isZipped = realmAttachment.isZipped
        sha256 = realmAttachment.sha256
        type = realmAttachment.type
        
        if let realmResource = realmAttachment.resource {
            resource = ResourceModel(realmResource: realmResource)
        }
        else {
            resource = nil
        }
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        
        var attributesContainer: KeyedDecodingContainer<AttributesKeys>?
        var relationshipsContainer: KeyedDecodingContainer<RelationshipsKeys>?
        var resourceContainer: KeyedDecodingContainer<DataCodingKeys>?
        
        do {
            attributesContainer = try container.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
            relationshipsContainer = try container.nestedContainer(keyedBy: RelationshipsKeys.self, forKey: .relationships)
            resourceContainer = try relationshipsContainer?.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .resource)
        }
        catch {
            // It's possible an Attachment doesn't have keys for attributes and relationships.
        }
        
        // attributes
        file = try attributesContainer?.decodeIfPresent(String.self, forKey: .file) ?? ""
        fileFilename = try attributesContainer?.decodeIfPresent(String.self, forKey: .fileFilename) ?? ""
        isZipped = try attributesContainer?.decodeIfPresent(Bool.self, forKey: .isZipped) ?? false
        sha256 = try attributesContainer?.decodeIfPresent(String.self, forKey: .sha256) ?? ""
                
        // relationships - resource
        resource = try resourceContainer?.decodeIfPresent(ResourceModel.self, forKey: .data)
    }
}
