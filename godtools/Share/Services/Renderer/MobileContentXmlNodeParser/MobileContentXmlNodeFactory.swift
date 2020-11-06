//
//  MobileContentXmlNodeFactory.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class MobileContentXmlNodeFactory {
    
    private let factory: [MobileContentXmlNodeType: MobileContentXmlNode.Type]
    
    required init() {
        
        let allNodeTypes: [MobileContentXmlNodeType] = MobileContentXmlNodeType.allCases
        
        var factory: [MobileContentXmlNodeType: MobileContentXmlNode.Type] = Dictionary()
        
        for nodeType in allNodeTypes {
            
            factory[nodeType] = MobileContentXmlNodeFactory.getNodeClass(nodeType: nodeType)
        }
        
        self.factory = factory
    }
    
    func getNode(nodeType: MobileContentXmlNodeType, xmlElement: XMLElement) -> MobileContentXmlNode? {
        
        guard let RendererNodeClass = factory[nodeType] else {
            return nil
        }
        
        return RendererNodeClass.init(xmlElement: xmlElement)
    }
    
    private static func getNodeClass(nodeType: MobileContentXmlNodeType) -> MobileContentXmlNode.Type {
        
        switch nodeType {
            
        case .contentParagraph:
            return ContentParagraphNode.self
        
        case .contentText:
            return ContentTextNode.self
            
        case .contentButton:
            return ContentButtonNode.self
            
        case .contentImage:
            return ContentImageNode.self
            
        case .contentLabel:
            return ContentLabelNode.self
            
        case .contentTab:
            return ContentTabNode.self
            
        case .contentTabs:
            return ContentTabsNode.self
            
        case .title:
            return TitleNode.self
            
        case .number:
            return NumberNode.self
            
        case .label:
            return LabelNode.self
            
        case .header:
            return HeaderNode.self
            
        case .heading:
            return HeadingNode.self
            
        case .hero:
            return HeroNode.self
            
        case .card:
            return CardNode.self
            
        case .cards:
            return CardsNode.self
            
        case .callToAction:
            return CallToActionNode.self
            
        case .page:
            return PageNode.self
            
        case .pages:
            return PagesNode.self
            
        case .tip:
            return TipNode.self
        }
    }
}
