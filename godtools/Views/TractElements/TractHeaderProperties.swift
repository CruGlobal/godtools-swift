//
//  TractHeaderProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/9/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractHeaderProperties: TractProperties {
    
    // MARK: - XML Properties
    
    var backgroundColor: UIColor?
    
    override func properties() -> [String]? {
        return ["backgroundColor"]
    }
    
    // MARK: - View Properties
    
    var includesNumber = false

}
