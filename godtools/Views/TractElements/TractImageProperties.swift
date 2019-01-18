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
    
    @objc var resource: String?
    
    override func defineProperties() {
        self.properties = ["resource"]
    }

}
