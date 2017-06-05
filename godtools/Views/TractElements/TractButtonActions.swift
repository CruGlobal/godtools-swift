//
//  TractButtonActions.swift
//  godtools
//
//  Created by Devserker on 5/29/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractButton {
    
    func buttonTarget() {
        if self.properties.type == .event {
            let values = self.properties.value!.components(separatedBy: ",")
            for value in values {
                sendMessageToElement(listener: value)
            }
        } else if self.properties.type == .url {
            if let url = URL(string: self.properties.value!) {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
}
