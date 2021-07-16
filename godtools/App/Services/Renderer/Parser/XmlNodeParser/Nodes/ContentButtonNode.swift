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
    
    required init(xmlElement: XMLElement, position: Int) {
    
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
        
        super.init(xmlElement: xmlElement, position: position)
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
    
    var buttonStyle: MobileContentButtonNodeStyle? {
        return MobileContentButtonNodeStyle(rawValue: style ?? "")
    }
    
    var buttonType: MobileContentButtonNodeType {
    
        guard let type = self.type else {
            return .unknown
        }
        
        return MobileContentButtonNodeType(rawValue: type) ?? .unknown
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

// MARK: - MobileContentRenderableNode

extension ContentButtonNode: MobileContentRenderableNode {
    
    var nodeContentIsRenderable: Bool {
        return buttonType != .unknown
    }
}
