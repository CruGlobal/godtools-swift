//
//  LanguageModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct LanguageModel: LanguageModelType, Codable {
    
    let code: String
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
        code = try attributesContainer?.decodeIfPresent(String.self, forKey: .code) ?? ""
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

extension LanguageModel {
    
    var localeId: BCP47LanguageIdentifier {
        return code
    }
    
    var languageCode: String {
        
        let locale = Locale(identifier: localeId)
        let languageCode: String?
        
        if #available(iOS 16, *) {
            languageCode = locale.language.languageCode?.identifier
        }
        else {
            languageCode = locale.languageCode
        }
        
        return languageCode ?? localeId
    }
    
    var scriptCode: String? {
        
        let locale = Locale(identifier: localeId)
        let scriptCode: String?
        
        if #available(iOS 16, *) {
            scriptCode = locale.language.script?.identifier
        }
        else {
            scriptCode = locale.scriptCode
        }
            
        return scriptCode
    }
}
