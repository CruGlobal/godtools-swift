//
//  ResourcesPlusLatestTranslationsAndAttachmentsCodable.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ResourcesPlusLatestTranslationsAndAttachmentsCodable: Codable {
    
    let resources: [ResourceCodable]
    let attachments: [AttachmentCodable]
    let translations: [TranslationCodable]
    
    enum RootKeys: String, CodingKey {
        case data = "data"
        case included = "included"
    }
    
    enum IncludedTypeKeys: String, CodingKey {
        case type = "type"
    }
    
    static var emptyModel: ResourcesPlusLatestTranslationsAndAttachmentsCodable {
        return ResourcesPlusLatestTranslationsAndAttachmentsCodable(resources: [], attachments: [], translations: [])
    }
    
    init(resources: [ResourceCodable], attachments: [AttachmentCodable], translations: [TranslationCodable]) {
        self.resources = resources
        self.attachments = attachments
        self.translations = translations
    }
    
    init(from decoder: Decoder) throws {
                
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        resources = Self.decodeResources(container: container)
        
        var includedUnkeyedContainer: UnkeyedDecodingContainer = try container.nestedUnkeyedContainer(forKey: .included)
        var includedDecoder: UnkeyedDecodingContainer = try container.nestedUnkeyedContainer(forKey: .included)
        
        var attachments: [AttachmentCodable] = Array()
        var translations: [TranslationCodable] = Array()
        
        while !includedUnkeyedContainer.isAtEnd {
            
            let container = try includedUnkeyedContainer.nestedContainer(keyedBy: IncludedTypeKeys.self)
            let type: String? = try container.decode(String.self, forKey: .type)
                        
            if type == "attachment" {
                let attachment: AttachmentCodable? = try includedDecoder.decode(AttachmentCodable.self)
                if let attachment = attachment {
                    attachments.append(attachment)
                }
            }
            else if type == "translation" {
                let translation: TranslationCodable? = try includedDecoder.decode(TranslationCodable.self)
                if let translation = translation {
                    translations.append(translation)
                }
            }
        }
        
        self.attachments = attachments
        self.translations = translations
    }
    
    private static func decodeResources(container: KeyedDecodingContainer<ResourcesPlusLatestTranslationsAndAttachmentsCodable.RootKeys>) -> [ResourceCodable] {
                
        do {
            let resources: [ResourceCodable] = try container.decode([ResourceCodable].self, forKey: .data)
            return resources
        }
        catch _ {

        }
        
        do {
            
            let resourceObject: ScriptJsonApiResponseDataObject<ResourceCodable> = try container.decode(ScriptJsonApiResponseDataObject<ResourceCodable>.self, forKey: .data)
            let resource: ResourceCodable = resourceObject.dataObject
            
            return [resource]
        }
        catch _ {
            
        }
        
        return []
    }
    
    func encode(to encoder: Encoder) throws {

    }
}
