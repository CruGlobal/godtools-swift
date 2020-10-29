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
    
    required init(xmlElement: XMLElement) {
    
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
}
