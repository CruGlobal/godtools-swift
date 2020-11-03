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
    
    private(set) var headerNode: HeaderNode?
    private(set) var heroNode: HeroNode?
    private(set) var cardsNode: CardsNode?
    private(set) var callToActionNode: CallToActionNode?
    
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
        
        if let headerNode = childNode as? HeaderNode {
            self.headerNode = headerNode
        }
        else if let heroNode = childNode as? HeroNode {
            self.heroNode = heroNode
        }
        else if let cardsNode = childNode as? CardsNode {
            self.cardsNode = cardsNode
        }
        else if let callToActionNode = childNode as? CallToActionNode {
            self.callToActionNode = callToActionNode
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
