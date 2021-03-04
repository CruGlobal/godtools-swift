//
//  ContentButtonNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//
import Foundation
import SWXMLHash

class ContentButtonNode: MobileContentXmlNode {
    
    private(set) var textNode: ContentTextNode?
    private(set) var analyticsEventsNode: AnalyticsEventsNode?
    
    let backgroundColor: String?
    let color: String?
    let events: [String]
    let style: String?
    let type: String?
    let url: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        backgroundColor = attributes["background-color"]?.text
        color = attributes["color"]?.text
        events = attributes["events"]?.text.components(separatedBy: " ") ?? []
        style = attributes["style"]?.text
        type = attributes["type"]?.text
        
        if var urlString = attributes["url"]?.text {
            let urlIsHttps: Bool = urlString.contains("https://")
            let urlIsHttp: Bool = urlString.contains("http://")
            if !urlIsHttps && !urlIsHttp {
                urlString = "http://" + urlString
            }
            url  = urlString
        }
        else {
            url = nil
        }
        
        super.init(xmlElement: xmlElement)
    }
    
    override func addChild(childNode: MobileContentXmlNode) {
        
        if let textNode = childNode as? ContentTextNode, self.textNode == nil {
            self.textNode = textNode
        }
        else if let analyticsEventsNode = childNode as? AnalyticsEventsNode {
            self.analyticsEventsNode = analyticsEventsNode
        }
        
        super.addChild(childNode: childNode)
    }
    
    func getBackgroundColor() -> MobileContentRGBAColor? {
        if let stringColor = backgroundColor {
            return MobileContentRGBAColor(stringColor: stringColor)
        }
        return nil
    }
    
    func getColor() -> MobileContentRGBAColor? {
        if let stringColor = color {
            return MobileContentRGBAColor(stringColor: stringColor)
        }
        return nil
    }
}

extension ContentButtonNode {
    
    var buttonStyle: MobileContentButtonNodeStyle {
        
        let defaultStyle: MobileContentButtonNodeStyle = .contained
        
        guard let style = self.style else {
            return defaultStyle
        }
        
        return MobileContentButtonNodeStyle(rawValue: style) ?? defaultStyle
    }
    
    var buttonType: MobileContentButtonNodeType {
    
        guard let type = self.type else {
            return .unknown
        }
        
        return MobileContentButtonNodeType(rawValue: type) ?? .unknown
    }
}

// MARK: - MobileContentRenderableNode

extension ContentButtonNode: MobileContentRenderableNode {
    
    var nodeContentIsRenderable: Bool {
        return buttonType != .unknown
    }
}
