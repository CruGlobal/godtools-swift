//
//  TractBindings.swift
//  godtools
//
//  Created by Devserker on 5/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractBindings: NSObject {
    
    static var pageBindings = [String: Int]()
    static var bindings = [String: BaseTractElement]()
    static var dismissBindings = [String: BaseTractElement]()
    
    static func clearAllBindings() {
        TractBindings.pageBindings.removeAll()
        TractBindings.bindings.removeAll()
        TractBindings.dismissBindings.removeAll()
    }
    
    static func setupBindings() {
        TractBindings.pageBindings = [String: Int]()
        TractBindings.bindings = [String: BaseTractElement]()
        TractBindings.dismissBindings = [String: BaseTractElement]()
    }
    
    static func addPageBinding(_ listener: String, _ number: Int){
        TractBindings.pageBindings[listener] = number
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
