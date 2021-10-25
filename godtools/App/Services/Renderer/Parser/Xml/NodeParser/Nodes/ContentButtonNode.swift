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
    
    private let backgroundColorString: String?
    private let colorString: String?
    private let styleString: String?
    private let typeString: String?
    
    private var textNode: ContentTextNode?
    private var analyticsEventsNode: AnalyticsEventsNode?
    
    let events: [MultiplatformEventId]
    let url: String?
    let icon: MobileContentButtonIcon? = nil
    
    required init(xmlElement: XMLElement) {
    
        fatalError("init(xmlElement:) has not been implemented")
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
    
    func getBackgroundColor() -> MobileContentColor? {
        if let stringColor = backgroundColorString {
            return MobileContentColor(stringColor: stringColor)
        }
        return nil
    }
    
    func getColor() -> MobileContentColor? {
        if let stringColor = colorString {
            return MobileContentColor(stringColor: stringColor)
        }
        return nil
    }
    
    func getTextColor() -> MobileContentColor? {
        return textNode?.getTextColor()
    }
    
    func getAnalyticsEvents() -> [AnalyticsEventModelType] {
        return analyticsEventsNode?.analyticsEventNodes ?? []
    }
    
    func watchVisibility(rendererState: MobileContentMultiplatformState, visibilityChanged: @escaping ((MobileContentVisibility) -> Void)) -> MobileContentFlowWatcherType {
        fatalError("Not implemented for xml node parser, moving to multiplatform parser.")
    }
}
