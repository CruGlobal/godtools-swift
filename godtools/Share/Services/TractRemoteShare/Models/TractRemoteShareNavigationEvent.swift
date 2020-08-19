//
//  TractRemoteShareNavigationEvent.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct TractRemoteShareNavigationEvent: Codable {
    
    let card: Int?
    let id: String?
    let identifier: ActionCableIdentifier?
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
    
    init(card: Int?, channel: String, channelId: String, locale: String?, page: Int?, tool: String?) {
        
        self.card = card
        self.id = UUID().uuidString
        self.identifier = ActionCableIdentifier(channel: channel, channelId: channelId)
        self.locale = locale
        self.page = page
        self.tool = tool
        self.type = "navigation-event"
    }
    
    init(from decoder: Decoder) throws {
                
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        let identifierString: String? = try container.decodeIfPresent(String.self, forKey: .identifier)
        
        if let identifierString = identifierString, let data = identifierString.data(using: .utf8) {
            do {
                identifier = try JSONDecoder().decode(ActionCableIdentifier.self, from: data)
            }
            catch {
                identifier = ActionCableIdentifier(channel: "", channelId: "")
            }
        }
        else {
            identifier = ActionCableIdentifier(channel: "", channelId: "")
        }
        
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
}
