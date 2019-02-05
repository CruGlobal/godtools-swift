//
//  TractFormProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/12/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractFormProperties: TractProperties {
    
    @objc var action: String = ""
    
    override func defineProperties() {
        self.properties = ["action"]
    }

}
