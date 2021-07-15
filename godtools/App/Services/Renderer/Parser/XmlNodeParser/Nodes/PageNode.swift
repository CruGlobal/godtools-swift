//
//  PageNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class PageNode: MobileContentXmlNode, PageModelType {
    
    private var headerNode: HeaderNode?
    private var heroNode: HeroNode?
    private var cardsNode: CardsNode?
    private var callToActionNode: CallToActionNode?
    private var modalsNode: ModalsNode?
    
    let backgroundColor: String?
    let backgroundImage: String?
    let backgroundImageAlign: [String]
    let backgroundImageScaleType: String
    let cardTextColor: String?
    let hidden: String?
    let listeners: [String]
    let primaryColor: String?
    let primaryTextColor: String?
    let textColor: String?
    let textScale: String?
    
    required init(xmlElement: XMLElement) {
   
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        backgroundColor = attributes["background-color"]?.text
        backgroundImage = attributes["background-image"]?.text
        
        if let backgroundImageAlignValues = attributes["background-image-align"]?.text, !backgroundImageAlignValues.isEmpty {
            backgroundImageAlign = backgroundImageAlignValues.components(separatedBy: " ")
        }
        else {
            backgroundImageAlign = [MobileContentBackgroundImageAlignType.center.rawValue]
        }
        backgroundImageScaleType = attributes["background-image-scale-type"]?.text ?? MobileContentBackgroundImageScaleType.fillHorizontally.rawValue
        cardTextColor = attributes["card-text-color"]?.text
        hidden = attributes["hidden"]?.text
        listeners = attributes["listeners"]?.text.components(separatedBy: " ") ?? []
        primaryColor = attributes["primary-color"]?.text
        primaryTextColor = attributes["primary-text-color"]?.text
        textColor = attributes["text-color"]?.text
        textScale = attributes["text-scale"]?.text

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
        else if let modalsNode = childNode as? ModalsNode {
            self.modalsNode = modalsNode
        }
    }
    
    var isHidden: Bool {
        return hidden == "true"
    }
    
    var hero: HeroModelType? {
        return heroNode
    }
    
    var callToAction: CallToActionModelType? {
        return callToActionNode
    }
    
    func getBackgroundColor() -> MobileContentRGBAColor? {
        if let stringColor = backgroundColor {
            return MobileContentRGBAColor(stringColor: stringColor)
        }
        return nil
    }
    
    func getCardTextColor() -> MobileContentRGBAColor? {
        if let stringColor = cardTextColor {
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

// MARK: - MobileContentRenderableNode

extension PageNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
