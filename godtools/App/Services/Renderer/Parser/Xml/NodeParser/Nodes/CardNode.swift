//
//  CardNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SWXMLHash

class CardNode: MobileContentXmlNode, CardModelType {
        
    private let backgroundImageAlignmentStrings: [String]
    private let backgroundImageScaleString: String?
    private let hiddenString: String?
    
    private var labelNode: LabelNode?
    private var analyticsEventsNode: AnalyticsEventsNode?
    
    let backgroundImage: String?
    let dismissListeners: [String]
    let listeners: [String]
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        backgroundImage = attributes["background-image"]?.text
        backgroundImageAlignmentStrings = attributes["background-image-align"]?.text.components(separatedBy: " ") ?? []
        backgroundImageScaleString = attributes["background-image-scale-type"]?.text
        dismissListeners = attributes["dismiss-listeners"]?.text.components(separatedBy: " ") ?? []
        hiddenString = attributes["hidden"]?.text
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
    
    var isHidden: Bool {
        return hiddenString == "true"
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
        
        guard let visibleCards: [CardNode] = cardsNode?.visibleCardNodes else {
            return defaultValue
        }
        
        return visibleCards.firstIndex(of: self) ?? defaultValue
    }
    
    var numberOfVisibleCards: Int {
        return cardsNode?.visibleCardNodes.count ?? 0
    }
    
    func getTextColor() -> UIColor? {
        return labelNode?.textNode?.getTextColor()
    }
    
    func getAnalyticsEvents() -> [AnalyticsEventModelType] {
        return analyticsEventsNode?.analyticsEventNodes ?? []
    }
}

// MARK: - MobileContentContainerNode

extension CardNode: MobileContentContainerNode {
    
    var buttonColor: MobileContentRGBAColor? {
        return nil
    }
    
    var buttonStyle: MobileContentButtonStyle? {
        return nil
    }
    
    var primaryColor: MobileContentRGBAColor? {
        return nil
    }
    
    var primaryTextColor: MobileContentRGBAColor? {
        return nil
    }
    
    var textAlignment: MobileContentTextAlignment? {
        return nil
    }
    
    var textColor: MobileContentRGBAColor? {
        return nil
    }
}
