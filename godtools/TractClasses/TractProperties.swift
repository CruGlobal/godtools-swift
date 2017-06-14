//
//  TractProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/13/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractProperties: XMLNode {
    
    var parentProperties: TractProperties?
    
    required init() {
        super.init()
    }
    
    func getTextProperties() -> TractTextContentProperties {
        return TractTextContentProperties()
    }

}
