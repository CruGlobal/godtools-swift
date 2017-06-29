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
        getParentCard()?.endCardEditing()
        
        let properties = buttonProperties()
        if properties.type == .event {
            let events = properties.events.components(separatedBy: " ")
            for event in events {
                sendMessageToElement(listener: event)
            }
        } else if properties.type == .url {
            if let url = URL(string: properties.url) {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
