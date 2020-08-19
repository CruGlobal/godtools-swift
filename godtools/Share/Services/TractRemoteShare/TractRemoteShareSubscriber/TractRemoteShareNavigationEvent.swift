//
//  TractRemoteShareNavigationEvent.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct TractRemoteShareNavigationEvent: Decodable {
    
    let card: Int?
    let id: String?
    let identifier: String?
    let locale: String?
    let page: Int?
    let tool: String?
    let type: String?
    
    enum RootKeys: String, CodingKey {
        
        case identifier = "identifier"
        case message = "message"
    }
    
    enum IdentifierKeys: String, CodingKey {
        
        case channel = "channel"
        case channelId = "channelId"
    }
    
    enum MessageKeys: String, CodingKey {
        
        case data = "data"
    }
    
    enum DataKeys: String, CodingKey {
        
        case attributes = "attributes"
        case id = "id"
        case type = "type"
    }
    
    enum AttributeKeys: String, CodingKey {
        
        case card = "card"
        case locale = "locale"
        case page = "page"
        case tool = "tool"
    }
    
    init(card: Int?, channelId: String, locale: String?, page: Int?, tool: String?) {
        
        self.card = card
        self.id = UUID().uuidString
        self.identifier = "{ \"channel\": \"SubscribeChannel\",\"channelId\": \"\(channelId)\" }"
        self.locale = locale
        self.page = page
        self.tool = tool
        self.type = "navigation-event"
    }
    
    init(from decoder: Decoder) throws {
                
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        identifier = try container.decodeIfPresent(String.self, forKey: .identifier)
        
        var messageContainer: KeyedDecodingContainer<MessageKeys>?
        var dataContainer: KeyedDecodingContainer<DataKeys>?
        var attributesContainer: KeyedDecodingContainer<AttributeKeys>?
        
        do {
            messageContainer = try container.nestedContainer(keyedBy: MessageKeys.self, forKey: .message)
            dataContainer = try messageContainer?.nestedContainer(keyedBy: DataKeys.self, forKey: .data)
            attributesContainer = try dataContainer?.nestedContainer(keyedBy: AttributeKeys.self, forKey: .attributes)
        }
        catch {
            
        }
        
        card = try attributesContainer?.decodeIfPresent(Int.self, forKey: .card)
        id = try dataContainer?.decodeIfPresent(String.self, forKey: .id)
        locale = try attributesContainer?.decodeIfPresent(String.self, forKey: .locale)
        page = try attributesContainer?.decodeIfPresent(Int.self, forKey: .page)
        tool = try attributesContainer?.decodeIfPresent(String.self, forKey: .tool)
        type = try dataContainer?.decodeIfPresent(String.self, forKey: .type)
    }
    
    var encodedObject: [String: Any] {
        
        // attributes
        var attributes: [String: Any] = Dictionary()
        
        if let card = self.card {
            attributes.updateValue(card, forKey: AttributeKeys.card.rawValue)
        }
        if let locale = self.locale {
            attributes.updateValue(locale, forKey: AttributeKeys.locale.rawValue)
        }
        if let page = self.page {
            attributes.updateValue(page, forKey: AttributeKeys.page.rawValue)
        }
        if let tool = self.tool {
            attributes.updateValue(tool, forKey: AttributeKeys.tool.rawValue)
        }
        
        // data
        var data: [String: Any] = Dictionary()
        
        if !attributes.isEmpty {
            data.updateValue(attributes, forKey: DataKeys.attributes.rawValue)
        }
        if let id = self.id {
            data.updateValue(id, forKey: DataKeys.id.rawValue)
        }
        if let type = self.type {
            data.updateValue(type, forKey: DataKeys.type.rawValue)
        }
        
        // messages
        var message: [String: Any] = Dictionary()
        
        message.updateValue(data, forKey: MessageKeys.data.rawValue)
        
        // encodedObject
        var encodedObject: [String: Any] = Dictionary()
        
        if let identifier = self.identifier {
            encodedObject.updateValue(identifier, forKey: RootKeys.identifier.rawValue)
        }
        
        encodedObject.updateValue(message, forKey: RootKeys.message.rawValue)
        
        return encodedObject
    }
}
