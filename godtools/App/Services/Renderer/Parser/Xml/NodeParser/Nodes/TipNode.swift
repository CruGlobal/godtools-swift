//
//  TipNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class TipNode: MobileContentXmlNode, TipModelType {
        
    private let tipTypeString: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        if let tipTypeAttribute = attributes["type"] {
            tipTypeString = tipTypeAttribute.text
        }
        else {
            tipTypeString = nil
        }
        
        super.init(xmlElement: xmlElement)
    }
    
    private var pagesNode: PagesNode? {
        return children.first as? PagesNode
    }
    
    var tipType: MobileContentTrainingTipType {
        
        let defaultTipType: MobileContentTrainingTipType = .unknown
        
        guard let tipTypeString = self.tipTypeString else {
            return defaultTipType
        }
        
        return MobileContentTrainingTipType(rawValue: tipTypeString) ?? defaultTipType
    }
    
    var pages: [PageModelType] {
        
        guard let pagesNode = self.pagesNode else {
            return Array()
        }
        
        return pagesNode.pages
    }
}
