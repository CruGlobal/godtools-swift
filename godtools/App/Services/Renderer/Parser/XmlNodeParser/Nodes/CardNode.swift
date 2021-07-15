//
//  CardNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class CardNode: MobileContentXmlNode, CardModelType {
        
    private var labelNode: LabelNode?
    private var analyticsEventsNode: AnalyticsEventsNode?
    
    let backgroundImage: String?
    let backgroundImageAlign: [String]
    let backgroundImageScaleType: String
    let dismissListeners: [String]
    let hidden: String?
    let listeners: [String]
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        backgroundImage = attributes["background-image"]?.text
        if let backgroundImageAlignValues = attributes["background-image-align"]?.text, !backgroundImageAlignValues.isEmpty {
            backgroundImageAlign = backgroundImageAlignValues.components(separatedBy: " ")
        }
        else {
            backgroundImageAlign = [MobileContentBackgroundImageAlignType.center.rawValue]
        }
        backgroundImageScaleType = attributes["background-image-scale-type"]?.text ?? MobileContentBackgroundImageScaleType.fillHorizontally.rawValue
        dismissListeners = attributes["dismiss-listeners"]?.text.components(separatedBy: " ") ?? []
        hidden = attributes["hidden"]?.text
        listeners = attributes["listeners"]?.text.components(separatedBy: " ") ?? []
        
        super.init(xmlElement: xmlElement)
    }
    
    override func addChild(childNode: MobileContentXmlNode) {
        
        if let labelNode = childNode as? LabelNode {
            self.labelNode = labelNode
        }
        else if let analyticsEventsNode = childNode as? AnalyticsEventsNode {
            self.analyticsEventsNode = analyticsEventsNode
        }
        
        super.addChild(childNode: childNode)
    }
    
    private var cardsNode: CardsNode? {
        return parent as? CardsNode
    }
    
    private func recurseForFirstTrainingTipNode(nodes: [MobileContentXmlNode]) -> TrainingTipNode? {
        
        for node in nodes {
            
            if let trainingTipNode = node as? TrainingTipNode {
                return trainingTipNode
            }
            
            if let trainingTipNode: TrainingTipNode = recurseForFirstTrainingTipNode(nodes: node.children) {
                return trainingTipNode
            }
        }
        
        return nil
    }
    
    var isHidden: Bool {
        return hidden == "true"
    }
    
    var hasTrainingTip: Bool {
        let trainingTipNode: TrainingTipNode? = recurseForFirstTrainingTipNode(nodes: [self])
        return trainingTipNode != nil
    }
    
    var text: String? {
        return labelNode?.textNode?.text
    }
    
    var cardPositionInVisibleCards: Int {
        
        let defaultValue: Int = 0
        
        guard let visibleCards: [CardNode] = cardsNode?.visibleCards else {
            return defaultValue
        }
        
        return visibleCards.firstIndex(of: self) ?? defaultValue
    }
    
    var numberOfVisibleCards: Int {
        return cardsNode?.visibleCards.count ?? 0
    }
    
    func getTextColor() -> MobileContentRGBAColor? {
        return labelNode?.textNode?.getTextColor()
    }
    
    func getAnalyticsEvents() -> [AnalyticsEventModelType] {
        return analyticsEventsNode?.analyticsEventNodes ?? []
    }
}

// MARK: - MobileContentRenderableNode

extension CardNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}

// MARK: - MobileContentContainerNode

extension CardNode: MobileContentContainerNode {
    
    var buttonColor: MobileContentRGBAColor? {
        return nil
    }
    
    var buttonStyle: MobileContentButtonNodeStyle? {
        return nil
    }
    
    var primaryColor: MobileContentRGBAColor? {
        return nil
    }
    
    var primaryTextColor: MobileContentRGBAColor? {
        return nil
    }
    
    var textAlignment: MobileContentTextAlign? {
        return nil
    }
    
    var textColor: MobileContentRGBAColor? {
        return nil
    }
}
