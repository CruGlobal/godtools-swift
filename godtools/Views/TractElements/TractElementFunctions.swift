//
//  TractElementOperationFunctions.swift
//  godtools
//
//  Created by Devserker on 5/1/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

extension BaseTractElement {
    
    func buildElementForDictionary(_ data: XMLIndexer, startOnY yPosition: CGFloat) -> BaseTractElement {
        let xmlManager = XMLManager()
        let nodeClassType = xmlManager.parser.getNodeClass(data)
        
        if nodeClassType == TractModals.self || nodeClassType == TractEmails.self || nodeClassType == TractEmail.self {
            return nodeClassType.init(data: data, parent: self)
        } else {
            return nodeClassType.init(data: data, startOnY: yPosition, parent: self)
        }
    }
    
    func elementListeners() -> [String]? {
        return nil
    }
    
    func elementDismissListeners() -> [String]? {
        return nil
    }
    
    func sendMessageToElement(listener: String) {
        if TractBindings.bindings[listener] != nil {
            guard let view = TractBindings.bindings[listener] else { return }
            view.receiveMessage()
        }
        
        if TractBindings.dismissBindings[listener] != nil {
            guard let view = TractBindings.dismissBindings[listener] else { return }
            view.receiveDismissMessage()
        }
        
        if TractBindings.pageBindings[listener] != nil {
            NotificationCenter.default.post(name: .moveToPageNotification, object: nil, userInfo: ["pageListener": listener])
        }
    }
    
    func receiveMessage() { }
    
    func receiveDismissMessage() { }
    
}
