//
//  TractImageProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/12/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractImageProperties: TractProperties {
    
    // MARK: - XML Properties
    
    var resource: UIColor?
    
    override func properties() -> [String]? {
        return ["resource"]
    }

}
