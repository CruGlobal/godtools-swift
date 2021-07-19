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
    private let backgroundImageAlignmentStrings: [String]
    private let backgroundImageScaleString: String?
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
    let listeners: [String]
        
    required init(xmlElement: XMLElement) {
   
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        backgroundColorString = attributes["background-color"]?.text
        backgroundImage = attributes["background-image"]?.text
        backgroundImageAlignmentStrings = attributes["background-image-align"]?.text.components(separatedBy: " ") ?? []
        backgroundImageScaleString = attributes["background-image-scale-type"]?.text
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
    
    var backgroundImageAlignments: [MobileContentBackgroundImageAlignment] {
        let backgroundImageAlignments: [MobileContentBackgroundImageAlignment] = backgroundImageAlignmentStrings.compactMap({MobileContentBackgroundImageAlignment(rawValue: $0.lowercased())})
        if !backgroundImageAlignments.isEmpty {
            return backgroundImageAlignments
        }
        else {
            return [.center]
        }
    }
    
    var backgroundImageScale: MobileContentBackgroundImageScale {
        let defaultValue: MobileContentBackgroundImageScale = .fillHorizontally
        guard let backgroundImageScaleString = self.backgroundImageScaleString else {
            return defaultValue
        }
        return MobileContentBackgroundImageScale(rawValue: backgroundImageScaleString) ?? defaultValue
    }
    
    var textScale: MobileContentTextScale {
        return MobileContentTextScale(textScaleString: textScaleString)
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
    
    func getBackgroundColor() -> MobileContentColor? {
        if let stringColor = backgroundColorString {
            return MobileContentColor(stringColor: stringColor)
        }
        return nil
    }
        
    func getCardTextColor() -> MobileContentColor? {
        if let stringColor = cardTextColorString {
            return MobileContentColor(stringColor: stringColor)
        }
        return nil
    }
    
    func getPrimaryColor() -> MobileContentColor? {
        if let stringColor = primaryColorString {
            return MobileContentColor(stringColor: stringColor)
        }
        return nil
    }
    
    func getPrimaryTextColor() -> MobileContentColor? {
        if let stringColor = primaryTextColorString {
            return MobileContentColor(stringColor: stringColor)
        }
        return nil
    }

    func getTextColor() -> MobileContentColor? {
        if let stringColor = textColorString {
            return MobileContentColor(stringColor: stringColor)
        }
        return nil
    }
}
