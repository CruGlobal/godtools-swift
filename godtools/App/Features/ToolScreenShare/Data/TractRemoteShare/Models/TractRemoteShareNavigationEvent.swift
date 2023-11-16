//
//  TractRemoteShareNavigationEvent.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct TractRemoteShareNavigationEvent: Codable {
    
    let message: TractRemoteShareNavigationEvent.Message?
    let identifier: ActionCableIdentifier?
    
    enum RootKeys: String, CodingKey {
        
        case message = "message"
        case identifier = "identifier"
    }
    
    struct Message: Codable {
        
        let data: TractRemoteShareNavigationEvent.Data?
        
        enum RootKeys: String, CodingKey {
            
            case data = "data"
        }
    }
    
    struct Data: Codable {
        
        let attributes: TractRemoteShareNavigationEvent.Attributes?
        let id: String
        let type: String
        
        enum RootKeys: String, CodingKey {
            
            case attributes = "attributes"
            case id = "id"
            case type = "type"
        }
        
        init(attributes: TractRemoteShareNavigationEvent.Attributes) {
            
            self.attributes = attributes
            self.id = UUID().uuidString
            self.type = "navigation-event"
        }
    }
    
    struct Attributes: Codable {
        
        let card: Int?
        let locale: String?
        let page: Int?
        let tool: String?
        
        enum RootKeys: String, CodingKey {
            
            case card = "card"
            case locale = "locale"
            case page = "page"
            case tool = "tool"
        }
    }
    
    init(card: Int?, channel: String, channelId: String, locale: String?, page: Int?, tool: String?) {
        
        let attributes = TractRemoteShareNavigationEvent.Attributes(card: card, locale: locale, page: page, tool: tool)
        let data = TractRemoteShareNavigationEvent.Data(attributes: attributes)
        
        self.message = TractRemoteShareNavigationEvent.Message(data: data)
        self.identifier = ActionCableIdentifier(channel: channel, channelId: channelId)
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
                
        do {
                        
            self.message = try container.decodeIfPresent(TractRemoteShareNavigationEvent.Message.self, forKey: .message)
        }
        catch {
            self.message = nil
        }
    }
}
