//
//  TrainingTipNode.swift
//  godtools
//
//  Created by Levi Eggert on 11/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class TrainingTipNode: MobileContentXmlNode, TrainingTipModelType {
    
    let id: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        id = attributes["id"]?.text
        
        super.init(xmlElement: xmlElement)
    }
    
    required init(trainingTipId: String, xmlElement: XMLElement) {
        
        self.id = trainingTipId
        
        super.init(xmlElement: xmlElement)
    }
    
    var tip: TipModelType? {
        return nil
    }
}
