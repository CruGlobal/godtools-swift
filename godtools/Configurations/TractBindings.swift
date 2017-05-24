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
    
    static func setupBindings() {
        TractBindings.bindings = [String: BaseTractElement]()
    }
    
    static func addBindings(_ element: BaseTractElement) {
        if element.elementListener() != "" {
            TractBindings.bindings[element.elementListener()] = element
        }
    }

}
