//
//  RealmResource.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmResource: Object, ResourceType {
    
    @objc dynamic var id: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var attributes: RealmResourceAttributes?
    let latestTranslations = List<RealmTranslation>()
    let attachments = List<RealmAttachment>()
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case attributes = "attributes"
        case relationships = "relationships"
        
    }
    
    enum RelationshipsCodingKeys: String, CodingKey {
        case attachments = "attachments"
        case latestTranslations = "latest-translations"
    }
    
    enum DataCodingKey: String, CodingKey {
        case data = "data"
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        
        //attributes
        attributes = try container.decode(RealmResourceAttributes.self, forKey: .attributes)
        
        //relationships
        let relationshipsContainer = try container.nestedContainer(keyedBy: RelationshipsCodingKeys.self, forKey: .relationships)
        
        // relationships - latest-translations
        let latestTranslationsContainer = try relationshipsContainer.nestedContainer(keyedBy: DataCodingKey.self, forKey: .latestTranslations)
        let latestTranslationsList = try latestTranslationsContainer.decode([RealmTranslation].self, forKey: .data)
        latestTranslations.append(objectsIn: latestTranslationsList)
        
        // relationships - attachments
        let attachmentsContainer = try relationshipsContainer.nestedContainer(keyedBy: DataCodingKey.self, forKey: .attachments)
        let attachmentsList = try attachmentsContainer.decode([RealmAttachment].self, forKey: .data)
        attachments.append(objectsIn: attachmentsList)
                
        super.init()
    }
    
    func encode(to encoder: Encoder) throws {
        fatalError("Encoder not implemented.")
    }
    
    required init() {
        super.init()
    }
}
