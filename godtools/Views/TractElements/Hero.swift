//
//  Hero.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class Hero: BaseTractElement {
    var children = [BaseTractElement]()
    
    var textScale = Float(3.0)
    var textColor: UIColor?
    
    override func buildContent(_ properties: Dictionary<String, Any>) {
    }
        
}
