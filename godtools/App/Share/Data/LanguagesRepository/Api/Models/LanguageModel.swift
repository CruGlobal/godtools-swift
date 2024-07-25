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
    let forceLanguageName: Bool
    
    enum RootKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case attributes = "attributes"
    }
    
    enum AttributesKeys: String, CodingKey {
        case code = "code"
        case name = "name"
        case direction = "direction"
        case forceLanguageName = "force-language-name"
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
        
        // TODO: (GT-2399) Remove tempCode override.  This is a temporary Taglish label until production switches to the fil-x-taglish language tag.
        var tempCode: String = try attributesContainer?.decodeIfPresent(BCP47LanguageIdentifier.self, forKey: .code) ?? ""
        if tempCode == "en-PH" {
            tempCode = "fil-x-taglish"
        }
        
        code = tempCode// try attributesContainer?.decodeIfPresent(BCP47LanguageIdentifier.self, forKey: .code) ?? "" // TODO: (GT-2399) Remove tempCode and replace with commented out line.
        direction = try attributesContainer?.decodeIfPresent(String.self, forKey: .direction) ?? ""
        name = try attributesContainer?.decodeIfPresent(String.self, forKey: .name) ?? ""
        forceLanguageName = try attributesContainer?.decodeIfPresent(Bool.self, forKey: .forceLanguageName) ?? false
    }
    
    init(model: LanguageModelType) {
        
        code = model.code
        direction = model.direction
        id = model.id
        name = model.name
        type = model.type
        forceLanguageName = model.forceLanguageName
    }
}

extension LanguageModel: Equatable {
    static func == (this: LanguageModel, that: LanguageModel) -> Bool {
        return this.id == that.id
    }
}
