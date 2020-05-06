//
//  TractTabProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/12/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractTabProperties: TractProperties {

    @objc var listeners: String = ""

    override func defineProperties() {
        self.properties = ["listeners"]
    }
}
