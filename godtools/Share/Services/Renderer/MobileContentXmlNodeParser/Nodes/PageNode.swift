//
//  PageNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class PageNode: MobileContentXmlNode {
    
    private(set) var header: HeaderNode?
    private(set) var hero: HeroNode?
    private(set) var cards: CardsNode?
    private(set) var callToAction: CallToActionNode?
    
    let backgroundColor: String?
    let backgroundImage: String?
    let backgroundImageScaleType: String?
    let primaryColor: String?
    let primaryTextColor: String?
    let textColor: String?
    
    required init(xmlElement: XMLElement) {
   
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        backgroundColor = attributes["background-color"]?.text
        backgroundImage = attributes["background-image"]?.text
        backgroundImageScaleType = attributes["background-image-scale-type"]?.text
        primaryColor = attributes["primary-color"]?.text
        primaryTextColor = attributes["primary-text-color"]?.text
        textColor = attributes["text-color"]?.text

        super.init(xmlElement: xmlElement)
    }
    
    override func addChild(childNode: MobileContentXmlNode) {
        super.addChild(childNode: childNode)
        
        if let header = childNode as? HeaderNode {
            self.header = header
        }
        else if let hero = childNode as? HeroNode {
            self.hero = hero
        }
        else if let cards = childNode as? CardsNode {
            self.cards = cards
        }
        else if let callToAction = childNode as? CallToActionNode {
            self.callToAction = callToAction
        }
    }
    
    func getBackgroundColor() -> MobileContentRGBAColor? {
        if let stringColor = backgroundColor {
            return MobileContentRGBAColor(stringColor: stringColor)
        }
        return nil
    }
    
    func getPrimaryColor() -> MobileContentRGBAColor? {
        if let stringColor = primaryColor {
            return MobileContentRGBAColor(stringColor: stringColor)
        }
        return nil
    }
    
    func getPrimaryTextColor() -> MobileContentRGBAColor? {
        if let stringColor = primaryTextColor {
            return MobileContentRGBAColor(stringColor: stringColor)
        }
        return nil
    }
    
    func getTextColor() -> MobileContentRGBAColor? {
        if let stringColor = textColor {
            return MobileContentRGBAColor(stringColor: stringColor)
        }
        return nil
    }
}
