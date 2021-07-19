//
//  ContentButtonNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//
import Foundation
import SWXMLHash

class ContentButtonNode: MobileContentXmlNode, ContentButtonModelType {
    
    private var textNode: ContentTextNode?
    private var analyticsEventsNode: AnalyticsEventsNode?
    
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
    
    var buttonStyle: MobileContentButtonStyle? {
        
        let defaultStyle: MobileContentButtonStyle? = nil
        
        guard let style = self.style?.lowercased() else {
            return defaultStyle
        }
        
        if style == "contained" {
            return .contained
        }
        else if style == "outlined" {
            return .outlined
        }
        
        return defaultStyle
    }
    
    var buttonType: MobileContentButtonType {
    
        let defaultType: MobileContentButtonType = .unknown
        
        guard let type = self.type?.lowercased() else {
            return defaultType
        }
        
        if type == "event" {
            return .event
        }
        else if type == "url" {
            return .url
        }
        
        return defaultType
    }
    
    var text: String? {
        return textNode?.text
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
    
    func getTextColor() -> MobileContentRGBAColor? {
        return textNode?.getTextColor()
    }
    
    func getAnalyticsEvents() -> [AnalyticsEventModelType] {
        return analyticsEventsNode?.analyticsEventNodes ?? []
    }
}
