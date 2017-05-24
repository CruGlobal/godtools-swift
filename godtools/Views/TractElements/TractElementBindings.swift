//
//  TractElementBindings.swift
//  godtools
//
//  Created by Devserker on 5/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

extension BaseTractElement {
    
    @nonobjc static var tractElementsBindings = [String: BaseTractElement]()
    
    func setupBindings() {
        BaseTractElement.tractElementsBindings = [String: BaseTractElement]()
    }
    
    func addBindings(_ element: BaseTractElement) {
        if element.getListener() != "" {
            BaseTractElement.tractElementsBindings[element.getListener()] = element
        }
    }
    
    func sendMessageToView(tag: String) {
        if BaseTractElement.tractElementsBindings[tag] != nil {
            guard let view = BaseTractElement.tractElementsBindings[tag] else { return }
            view.receiveMessage()
        }
    }
    
}
