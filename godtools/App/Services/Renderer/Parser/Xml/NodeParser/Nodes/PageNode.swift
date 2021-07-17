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
    
    private let backgroundColorString: String?
    private let cardTextColorString: String?
    private let hiddenString: String?
    private let primaryColorString: String?
    private let primaryTextColorString: String?
    private let textColorString: String?
    private let textScaleString: String?
    
    private var headerNode: HeaderNode?
    private var heroNode: HeroNode?
    private var cardsNode: CardsNode?
    private var callToActionNode: CallToActionNode?
    private var modalsNode: ModalsNode?
    
    let uuid: String = UUID().uuidString
    let backgroundImage: String?
    let backgroundImageAlign: [String]
    let backgroundImageScaleType: String
    let listeners: [String]
        
    required init(xmlElement: XMLElement) {
   
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        backgroundColorString = attributes["background-color"]?.text
        backgroundImage = attributes["background-image"]?.text
        
        if let backgroundImageAlignValues = attributes["background-image-align"]?.text, !backgroundImageAlignValues.isEmpty {
            backgroundImageAlign = backgroundImageAlignValues.components(separatedBy: " ")
        }
        else {
            backgroundImageAlign = [MobileContentBackgroundImageAlignType.center.rawValue]
        }
        backgroundImageScaleType = attributes["background-image-scale-type"]?.text ?? MobileContentBackgroundImageScaleType.fillHorizontally.rawValue
        cardTextColorString = attributes["card-text-color"]?.text
        hiddenString = attributes["hidden"]?.text
        listeners = attributes["listeners"]?.text.components(separatedBy: " ") ?? []
        primaryColorString = attributes["primary-color"]?.text
        primaryTextColorString = attributes["primary-text-color"]?.text
        textColorString = attributes["text-color"]?.text
        textScaleString = attributes["text-scale"]?.text

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
    
    var textScale: Double {
        if let stringValue = textScaleString, let doubleValue = Double(stringValue) {
            return doubleValue
        }
        return 1
    }
    
    var isHidden: Bool {
        return hiddenString == "true"
    }
    
    var hero: HeroModelType? {
        return heroNode
    }
    
    var callToAction: CallToActionModelType? {
        return callToActionNode
    }
    
    var backgroundColor: UIColor? {
        if let stringColor = backgroundColorString {
            return MobileContentRGBAColor(stringColor: stringColor).color
        }
        return nil
    }
    
    var cardTextColor: UIColor? {
        if let stringColor = cardTextColorString {
            return MobileContentRGBAColor(stringColor: stringColor).color
        }
        return nil
    }
    
    var primaryColor: UIColor? {
        if let stringColor = primaryColorString {
            return MobileContentRGBAColor(stringColor: stringColor).color
        }
        return nil
    }
    
    var primaryTextColor: UIColor? {
        if let stringColor = primaryTextColorString {
            return MobileContentRGBAColor(stringColor: stringColor).color
        }
        return nil
    }
    
    var textColor: UIColor? {
        if let stringColor = textColorString {
            return MobileContentRGBAColor(stringColor: stringColor).color
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
