//
//  HeaderNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class HeaderNode: MobileContentXmlNode, HeaderModelType {
    
    private let trainingTipNode: TrainingTipNode?
    
    private var numberNode: NumberNode?
    private var titleNode: TitleNode?
    
    let trainingTipId: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        let trainingTipId: String? = attributes["training:tip"]?.text
        let trainingTipNode: TrainingTipNode?
        
        if let trainingTipId = trainingTipId {
            trainingTipNode = TrainingTipNode(trainingTipId: trainingTipId, xmlElement: xmlElement)
        }
        else {
            trainingTipNode = nil
        }
        
        self.trainingTipId = trainingTipId
        self.trainingTipNode = trainingTipNode
        
        super.init(xmlElement: xmlElement)
        
        if let trainingTipNode = trainingTipNode {
            addChild(childNode: trainingTipNode)
        }
    }
    
    override func addChild(childNode: MobileContentXmlNode) {
        
        super.addChild(childNode: childNode)
        
        if let numberNode = childNode as? NumberNode {
            self.numberNode = numberNode
        }
        
        if let titleNode = children.last as? TitleNode {
            self.titleNode = titleNode
        }
    }
    
    var trainingTip: TrainingTipModelType? {
        return trainingTipNode
    }
}
