//
//  TractBindings.swift
//  godtools
//
//  Created by Devserker on 5/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractBindings: NSObject {
    
    @nonobjc static var bindings = [String: BaseTractElement]()
    @nonobjc static var dismissBindings = [String: BaseTractElement]()
    
    static func setupBindings() {
        TractBindings.bindings = [String: BaseTractElement]()
        TractBindings.dismissBindings = [String: BaseTractElement]()
    }
    
    static func addBindings(_ element: BaseTractElement) {
        TractBindings.addOpeningBindings(element)
        TractBindings.addDismissBindings(element)
    }
    
    static func addOpeningBindings(_ element: BaseTractElement) {
        if element.elementListeners() == nil {
            return
        }
        
        for listener in element.elementListeners()! {
            TractBindings.bindings[listener] = element
        }
    }
    
    static func addDismissBindings(_ element: BaseTractElement) {
        if element.elementDismissListeners() == nil {
            return
        }
        
        for listener in element.elementDismissListeners()! {
            TractBindings.dismissBindings[listener] = element
        }
    }

}
