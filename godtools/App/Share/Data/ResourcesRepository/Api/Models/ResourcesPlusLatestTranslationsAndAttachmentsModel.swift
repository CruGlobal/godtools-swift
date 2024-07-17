//
//  ResourcesPlusLatestTranslationsAndAttachmentsModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ResourcesPlusLatestTranslationsAndAttachmentsModel: Codable {
    
    let resources: [ResourceModel]
    let attachments: [AttachmentModel]
    let translations: [TranslationModel]
    
    enum RootKeys: String, CodingKey {
        case data = "data"
        case included = "included"
    }
    
    enum IncludedTypeKeys: String, CodingKey {
        case type = "type"
    }
    
    static var emptyModel: ResourcesPlusLatestTranslationsAndAttachmentsModel {
        return ResourcesPlusLatestTranslationsAndAttachmentsModel(resources: [], attachments: [], translations: [])
    }
    
    init(resources: [ResourceModel], attachments: [AttachmentModel], translations: [TranslationModel]) {
        self.resources = resources
        self.attachments = attachments
        self.translations = translations
    }
    
    init(from decoder: Decoder) throws {
                
        let container = try decoder.container(keyedBy: RootKeys.self)
        resources = try container.decode([ResourceModel].self, forKey: .data)
        
        var includedUnkeyedContainer: UnkeyedDecodingContainer = try container.nestedUnkeyedContainer(forKey: .included)
        var includedDecoder: UnkeyedDecodingContainer = try container.nestedUnkeyedContainer(forKey: .included)
        
        var attachments: [AttachmentModel] = Array()
        var translations: [TranslationModel] = Array()
        
        while !includedUnkeyedContainer.isAtEnd {
            
            let container = try includedUnkeyedContainer.nestedContainer(keyedBy: IncludedTypeKeys.self)
            let type: String? = try container.decode(String.self, forKey: .type)
                        
            if type == "attachment" {
                let attachment: AttachmentModel? = try includedDecoder.decode(AttachmentModel.self)
                if let attachment = attachment {
                    attachments.append(attachment)
                }
            }
            else if type == "translation" {
                let translation: TranslationModel? = try includedDecoder.decode(TranslationModel.self)
                if let translation = translation {
                    translations.append(translation)
                }
            }
        }
        
        self.attachments = attachments
        self.translations = translations
    }
    
    func encode(to encoder: Encoder) throws {

    }
}
