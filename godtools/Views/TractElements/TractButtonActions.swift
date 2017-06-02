//
//  TractButtonActions.swift
//  godtools
//
//  Created by Devserker on 5/29/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

extension TractButton {
    
    func buttonTarget() {
        let values = self.properties.value!.components(separatedBy: ",")
        for value in values {
            sendMessageToElement(listener: value)
        }
    }
    
}
