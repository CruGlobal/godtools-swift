//
//  LanguageModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct LanguageModel: LanguageModelType, Codable {
    
    let code: BCP47LanguageIdentifier
    let direction: String
    let id: String
    let name: String
    let type: String
    
    enum RootKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case attributes = "attributes"
    }
    
    enum AttributesKeys: String, CodingKey {
        case code = "code"
        case name = "name"
        case direction = "direction"
    }
    
    init(code: BCP47LanguageIdentifier, direction: String, id: String, name: String, type: String) {
        
        self.code = code
        self.direction = direction
        self.id = id
        self.name = name
        self.type = type
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        
        var attributesContainer: KeyedDecodingContainer<AttributesKeys>?

        do {
            attributesContainer = try container.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        }
        catch  {
            // It's possible that a Language doesn't have an attributes key.
        }
        
        // attributes
        code = try attributesContainer?.decodeIfPresent(BCP47LanguageIdentifier.self, forKey: .code) ?? ""
        direction = try attributesContainer?.decodeIfPresent(String.self, forKey: .direction) ?? ""
        name = try attributesContainer?.decodeIfPresent(String.self, forKey: .name) ?? ""
    }
    
    init(model: LanguageModelType) {
        
        code = model.code
        direction = model.direction
        id = model.id
        name = model.name
        type = model.type
    }
}

extension LanguageModel: Equatable {
    static func ==(lhs: LanguageModel, rhs: LanguageModel) -> Bool {
        return lhs.id == rhs.id
    }
}
