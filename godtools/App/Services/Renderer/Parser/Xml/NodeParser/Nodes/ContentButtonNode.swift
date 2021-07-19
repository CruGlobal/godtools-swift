//
//  ContentButtonNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//
import UIKit
import SWXMLHash

class ContentButtonNode: MobileContentXmlNode, ContentButtonModelType {
    
    private let backgroundColorString: String?
    private let colorString: String?
    private let styleString: String?
    private let typeString: String?
    
    private var textNode: ContentTextNode?
    private var analyticsEventsNode: AnalyticsEventsNode?
    
    let events: [String]
    let url: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        backgroundColorString = attributes["background-color"]?.text
        colorString = attributes["color"]?.text
        events = attributes["events"]?.text.components(separatedBy: " ") ?? []
        styleString = attributes["style"]?.text
        typeString = attributes["type"]?.text
        
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
    
    var style: MobileContentButtonStyle? {
        
        let defaultStyle: MobileContentButtonStyle? = nil
        
        guard let styleString = self.styleString?.lowercased() else {
            return defaultStyle
        }
        
        return MobileContentButtonStyle(rawValue: styleString) ?? defaultStyle
    }
    
    var type: MobileContentButtonType {
    
        let defaultType: MobileContentButtonType = .unknown
        
        guard let typeString = self.typeString?.lowercased() else {
            return defaultType
        }
        
        return MobileContentButtonType(rawValue: typeString) ?? defaultType
    }
    
    var text: String? {
        return textNode?.text
    }
    
    func getBackgroundColor() -> UIColor? {
        if let stringColor = backgroundColorString {
            return MobileContentRGBAColor(stringColor: stringColor).color
        }
        return nil
    }
    
    func getColor() -> UIColor? {
        if let stringColor = colorString {
            return MobileContentRGBAColor(stringColor: stringColor).color
        }
        return nil
    }
    
    func getTextColor() -> UIColor? {
        return textNode?.getTextColor()
    }
    
    func getAnalyticsEvents() -> [AnalyticsEventModelType] {
        return analyticsEventsNode?.analyticsEventNodes ?? []
    }
}
