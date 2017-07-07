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
                if sendMessageToElement(listener: event) == .failure {
                    break
                }
            }
        } else if properties.type == .url {
            let propertiesString = properties.url
            let stringWithProtocol = prependProtocolToURLStringIfNecessary(propertiesString)
            if let url = URL(string: stringWithProtocol) {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    private func prependProtocolToURLStringIfNecessary(_ original: String) -> String {
        if original.hasPrefix("http://") || original.hasPrefix("https://") {
            return original
        }
        
        return "http://\(original)"
    }
}
